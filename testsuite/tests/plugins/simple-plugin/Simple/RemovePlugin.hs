{-# LANGUAGE TypeFamilies, FlexibleContexts #-}
module Simple.RemovePlugin where

import Control.Monad.IO.Class
import Data.List (intercalate)
import Plugins
import Bag
import HscTypes
import TcRnTypes
import GHC.Hs.Extension
import GHC.Hs.Expr
import Outputable
import SrcLoc
import GHC.Hs
import GHC.Hs.Binds
import OccName
import RdrName
import Name
import Avail
import GHC.Hs.Dump

plugin :: Plugin
plugin = defaultPlugin { parsedResultAction = parsedPlugin
                       , typeCheckResultAction = typecheckPlugin
                       , spliceRunAction = metaPlugin'
                       , interfaceLoadAction = interfaceLoadPlugin'
                       }

parsedPlugin :: [CommandLineOption] -> ModSummary -> HsParsedModule
                  -> Hsc HsParsedModule
parsedPlugin [name, "parse"] _ pm
  = return $ pm { hpm_module = removeParsedBinding name (hpm_module pm) }
parsedPlugin _ _ pm = return pm

removeParsedBinding :: String -> Located HsModule
                         -> Located HsModule
removeParsedBinding name (L l m)
  = (L l (m { hsmodDecls = filter (notNamedAs name) (hsmodDecls m) } ))
  where notNamedAs name (L _ (ValD _ (FunBind { fun_id = L _ fid })))
          = occNameString (rdrNameOcc fid) /= name
        notNamedAs _ _ = True

typecheckPlugin :: [CommandLineOption] -> ModSummary -> TcGblEnv -> TcM TcGblEnv
typecheckPlugin [name, "typecheck"] _ tc
  = return $ tc { tcg_exports = filter (availNotNamedAs name) (tcg_exports tc)
                , tcg_binds = filterBag (notNamedAs name) (tcg_binds tc)
                }
  where notNamedAs name (L _ FunBind { fun_id = L _ fid })
          = occNameString (getOccName fid) /= name
        notNamedAs name (L _ AbsBinds { abs_binds = bnds })
          = all (notNamedAs name) bnds
        notNamedAs _ (L _ b) = True
typecheckPlugin _ _ tc = return tc

metaPlugin' :: [CommandLineOption] -> LHsExpr GhcTc -> TcM (LHsExpr GhcTc)
metaPlugin' [name, "meta"] (L l (HsWrap ne w (HsPar x (L _ (HsApp noExt (L _ (HsVar _ (L _ id))) e)))))
  | occNameString (getOccName id) == name
  = return (L l (HsWrap ne w (unLoc e)))
-- The test should always match this first case. If the desugaring changes
-- again in the future then the panic is more useful than the previous
-- inscrutable failure.
metaPlugin' _ meta = pprPanic "meta" (showAstData BlankSrcSpan meta)

interfaceLoadPlugin' :: [CommandLineOption] -> ModIface -> IfM lcl ModIface
interfaceLoadPlugin' [name, "interface"] iface
  = return $ iface { mi_exports = filter (availNotNamedAs name)
                                         (mi_exports iface)
                   }
interfaceLoadPlugin' _ iface = return iface

availNotNamedAs :: String -> AvailInfo -> Bool
availNotNamedAs name avail
  = occNameString (getOccName (availName avail)) /= name
