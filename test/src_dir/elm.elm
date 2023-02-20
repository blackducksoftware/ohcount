{-|
  {- This module contains some functions that are useful in several places in the -}
  {- program and don't belong to one specific other module. -}
-}
module Gnutella.Misc where

import Data.ByteString(ByteString)
import qualified Data.ByteString as BS

{-|

-}
composeWord32 :: ByteString -> Word32
composeWord32 s = shiftL byte4 24 + shiftL byte3 16 + shiftL byte2 8 + byte1
  where byte1, byte2, byte3, byte4 :: Word32
        [byte1, byte2, byte3, byte4] = map fromIntegral $ BS.unpack (BS.take 4 s)

{-| 
  Turns a Word32 into a tuple of Word8s. The tuple is little-endian: the least
  significant octet comes first.
-}
word32ToWord8s :: Word32 -> (Word8, Word8, Word8, Word8)
word32ToWord8s w = (fromIntegral (w .&. 0x000000ff)
                   ,fromIntegral (shiftR w 8 .&. 0x000000ff)
                   ,fromIntegral (shiftR w 16 .&. 0x000000ff)
                   ,fromIntegral (shiftR w 24 .&. 0x000000ff)
                   )

parseHostnameWithPort :: String -> IO (Maybe ((Word8, Word8, Word8, Word8)
                                             ,PortNumber))
parseHostnameWithPort str = do maybeHostName <- stringToIP hostNameStr
                               return $ (do portNum <- maybePortNum
                                            hostName <- maybeHostName
                                            return (hostName, portNum)
                                        )
  where hostNameStr = takeWhile (/=':') str
        maybePortNum  = case tail (dropWhile (/=':') str) of
                          [] -> Just $ 6346
                          s  -> case reads s of
                                  []     -> Nothing
                                  (x:xs) -> Just $ fromIntegral $ fst x

-- Again, hugs won't let us use regexes where they would be damn convenient
ipStringToBytes s =
    let ipBytesStrings = splitAtDots s
    in if all (all isNumber) ipBytesStrings
         then let bytesList = map (fst . head . reads) ipBytesStrings
              in Just (bytesList!!0
                      ,bytesList!!1
                      ,bytesList!!2
                      ,bytesList!!3
                      )
         else Nothing
  where splitAtDots s = foldr (\c (n:nums) -> if c == '.'
                                              then [] : n : nums
                                              else (c:n) : nums
                              ) [[]] s

ipBytesToString :: (Word8, Word8, Word8, Word8) -> String
ipBytesToString (b1, b2, b3, b4) = 
    concat $ intersperse "." $ map show [b1, b2, b3, b4]

stringToIP hostName = case ipStringToBytes hostName of
                        Just a  -> return (Just a)
                        Nothing -> do hostent <- getHostByName hostName
                                      let ipWord32 = head (hostAddresses hostent)
                                          ipWord8s = word32ToWord8s ipWord32
                                      return (Just ipWord8s)

{--}
instance Read PortNumber where
    readsPrec i = map (\(a, b) -> (fromIntegral a, b)) . (readsPrec i :: ReadS Word16)
--}
