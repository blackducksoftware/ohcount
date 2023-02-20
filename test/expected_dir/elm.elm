elm	comment	{-|
elm	comment	  {- This module contains some functions that are useful in several places in the -}
elm	comment	  {- program and don't belong to one specific other module. -}
elm	comment	-}
elm	code	module Gnutella.Misc where
elm	blank	
elm	code	import Data.ByteString(ByteString)
elm	code	import qualified Data.ByteString as BS
elm	blank	
elm	comment	{-|
elm	blank	
elm	comment	-}
elm	code	composeWord32 :: ByteString -> Word32
elm	code	composeWord32 s = shiftL byte4 24 + shiftL byte3 16 + shiftL byte2 8 + byte1
elm	code	  where byte1, byte2, byte3, byte4 :: Word32
elm	code	        [byte1, byte2, byte3, byte4] = map fromIntegral $ BS.unpack (BS.take 4 s)
elm	blank	
elm	comment	{-| 
elm	comment	  Turns a Word32 into a tuple of Word8s. The tuple is little-endian: the least
elm	comment	  significant octet comes first.
elm	comment	-}
elm	code	word32ToWord8s :: Word32 -> (Word8, Word8, Word8, Word8)
elm	code	word32ToWord8s w = (fromIntegral (w .&. 0x000000ff)
elm	code	                   ,fromIntegral (shiftR w 8 .&. 0x000000ff)
elm	code	                   ,fromIntegral (shiftR w 16 .&. 0x000000ff)
elm	code	                   ,fromIntegral (shiftR w 24 .&. 0x000000ff)
elm	code	                   )
elm	blank	
elm	code	parseHostnameWithPort :: String -> IO (Maybe ((Word8, Word8, Word8, Word8)
elm	code	                                             ,PortNumber))
elm	code	parseHostnameWithPort str = do maybeHostName <- stringToIP hostNameStr
elm	code	                               return $ (do portNum <- maybePortNum
elm	code	                                            hostName <- maybeHostName
elm	code	                                            return (hostName, portNum)
elm	code	                                        )
elm	code	  where hostNameStr = takeWhile (/=':') str
elm	code	        maybePortNum  = case tail (dropWhile (/=':') str) of
elm	code	                          [] -> Just $ 6346
elm	code	                          s  -> case reads s of
elm	code	                                  []     -> Nothing
elm	code	                                  (x:xs) -> Just $ fromIntegral $ fst x
elm	blank	
elm	comment	-- Again, hugs won't let us use regexes where they would be damn convenient
elm	code	ipStringToBytes s =
elm	code	    let ipBytesStrings = splitAtDots s
elm	code	    in if all (all isNumber) ipBytesStrings
elm	code	         then let bytesList = map (fst . head . reads) ipBytesStrings
elm	code	              in Just (bytesList!!0
elm	code	                      ,bytesList!!1
elm	code	                      ,bytesList!!2
elm	code	                      ,bytesList!!3
elm	code	                      )
elm	code	         else Nothing
elm	code	  where splitAtDots s = foldr (\c (n:nums) -> if c == '.'
elm	code	                                              then [] : n : nums
elm	code	                                              else (c:n) : nums
elm	code	                              ) [[]] s
elm	blank	
elm	code	ipBytesToString :: (Word8, Word8, Word8, Word8) -> String
elm	code	ipBytesToString (b1, b2, b3, b4) = 
elm	code	    concat $ intersperse "." $ map show [b1, b2, b3, b4]
elm	blank	
elm	code	stringToIP hostName = case ipStringToBytes hostName of
elm	code	                        Just a  -> return (Just a)
elm	code	                        Nothing -> do hostent <- getHostByName hostName
elm	code	                                      let ipWord32 = head (hostAddresses hostent)
elm	code	                                          ipWord8s = word32ToWord8s ipWord32
elm	code	                                      return (Just ipWord8s)
elm	blank	
elm	comment	{--}
elm	code	instance Read PortNumber where
elm	code	    readsPrec i = map (\(a, b) -> (fromIntegral a, b)) . (readsPrec i :: ReadS Word16)
elm	comment	--}
