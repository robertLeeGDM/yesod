{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE CPP #-}
-- | This module simply re-exports from other modules for your convenience.
module Yesod
    ( -- * Re-exports from yesod-core
      module Yesod.Core
    , module Yesod.Form
    , module Yesod.Json
    , module Yesod.Persist
      -- * Running your application
    , warp
    , warpDebug
    , develServer
      -- * Commonly referenced functions/datatypes
    , Application
    , liftIO
    , MonadBaseControl
      -- * Utilities
    , showIntegral
    , readIntegral
      -- * Hamlet library
      -- ** Hamlet
    , hamlet
    , xhamlet
    , HtmlUrl
    , Html
    , toHtml
      -- ** Julius
    , julius
    , JavascriptUrl
    , renderJavascriptUrl
      -- ** Cassius/Lucius
    , cassius
    , lucius
    , CssUrl
    , renderCssUrl
    ) where

import Yesod.Core
import Text.Hamlet
import Text.Cassius
import Text.Lucius
import Text.Julius

import Yesod.Form
import Yesod.Json
import Yesod.Persist
import Control.Monad.IO.Class (liftIO, MonadIO(..))
import Control.Monad.Trans.Control (MonadBaseControl)

import Network.Wai
import Network.Wai.Middleware.RequestLogger (logStdout)
import Network.Wai.Handler.Warp (run)
import System.IO (stderr, hPutStrLn)
#if MIN_VERSION_blaze_html(0, 5, 0)
import Text.Blaze.Html (toHtml)
#else
import Text.Blaze (toHtml)
#endif

showIntegral :: Integral a => a -> String
showIntegral x = show (fromIntegral x :: Integer)

readIntegral :: Num a => String -> Maybe a
readIntegral s =
    case reads s of
        (i, _):_ -> Just $ fromInteger i
        [] -> Nothing

-- | A convenience method to run an application using the Warp webserver on the
-- specified port. Automatically calls 'toWaiApp'.
warp :: (Yesod a, YesodDispatch a a) => Int -> a -> IO ()
warp port a = toWaiApp a >>= run port

-- | Same as 'warp', but also sends a message to stdout for each request, and
-- an \"application launched\" message as well. Can be useful for development.
warpDebug :: (Yesod a, YesodDispatch a a) => Int -> a -> IO ()
warpDebug port app = do
  hPutStrLn stderr $ "Application launched, listening on port " ++ show port
  waiApp <- toWaiApp app
  run port $ logStdout waiApp

-- | Run a development server, where your code changes are automatically
-- reloaded.
develServer :: Int -- ^ port number
            -> String -- ^ module name holding the code
            -> String -- ^ name of function providing a with-application
            -> IO ()

develServer port modu func =
    mapM_ putStrLn
        [ "Due to issues with GHC 7.0.2, you must now run the devel server"
        , "separately. To do so, ensure you have installed the "
        , "wai-handler-devel package >= 0.2.1 and run:"
        , concat
            [ "   wai-handler-devel "
            , show port
            , " "
            , modu
            , " "
            , func
            , " --yesod"
            ]
        , ""
        ]

