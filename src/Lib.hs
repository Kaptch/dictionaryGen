{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib where

import           Control.Lens
import           Control.Monad.Catch
import           Control.Monad.IO.Class
import           Data.Matrix               (Matrix, fromLists)
import           Data.Text                 (Text, pack)
import           Network.Yandex.Dictionary
import           Network.Yandex.Translate
import           System.Environment        (getEnv)
import           Text.LaTeX
import           Text.LaTeX.Base.Class     (comm1)

apiPreReq :: (MonadIO m, Control.Monad.Catch.MonadThrow m) => Text -> YandexApiT m DictResult
apiPreReq = dictLookup (Direction ("en", "ru")) (DictionaryParams Nothing [])

extractDictEntry :: DictAttrs
     -> (Text, Maybe Text, Maybe Text, Maybe Text, Maybe Text)
extractDictEntry d = ( d ^. text
                     , d ^. partOfSpeach
                     , d ^. transcription
                     , d ^. translates ^? each . text
                     , d ^. translates ^? each . examples . traverse . text)

enumerateList x = zip [1..length x] x

listFromTuple :: (Text, Maybe Text, Maybe Text, Maybe Text, Maybe Text) -> [Maybe Text]
listFromTuple (t1, t2, t3, t4, t5) = [Just t1, t2, t3, t4, t5]

appendEnumeration :: (Int, [Maybe Text]) -> [Maybe Text]
appendEnumeration (i, l) = Just (pack (show i)) : l

processResponse :: String -> IO [Maybe Text]
processResponse x = do
    key <- pack `fmap` getEnv "YANDEX_APIKEY_DICT"
    let apiConf = configureApi key
    resp <- runYandexApiSession apiConf $ apiPreReq $ pack x
    return $ (listFromTuple  . extractDictEntry . head) resp

tables :: Monad m => [[Maybe Text]] -> LaTeXT_ m
tables l = thePreamble >> document (theBody l)

thePreamble :: Monad m => LaTeXT_ m
thePreamble = do
    documentclass [] article
    usepackage ["utf8"] "inputenc"
    usepackage ["T1", "T2A"] "fontenc"
    usepackage [] "fontspec"
    usepackage ["T1"] "tipa"
    usepackage ["T3","OT2","T1"] "fontenc"
    usepackage ["english","russian"] "babel"
    comm1 "setmainfont" "Doulos SIL"

theBody :: Monad m => [[Maybe Text]] -> LaTeXT m ()
theBody l = flushleft $ matrixTabular (fmap textbf ["№","word","part of speach","transcription","translation","example"]) $
    fromLists l

instance Texy (Maybe Text) where
    texy (Just x) = texy x
    texy Nothing  = texy $ pack "—"
