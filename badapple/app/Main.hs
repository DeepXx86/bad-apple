module Main where

import Codec.Picture
import Control.Monad (forM_)
import System.Directory (listDirectory)
import Paths_badapple (getDataFileName)
import System.IO (hFlush, stdout)
import Control.Concurrent (threadDelay)
import Data.List (sort, isSuffixOf)
import System.Console.ANSI (clearScreen, setCursorPosition)

pixelToChar :: PixelRGB8 -> Char
pixelToChar (PixelRGB8 r g b) = 
    let brightness = (fromIntegral r + fromIntegral g + fromIntegral b) `div` 3
        asciiChars = ".:-=+*%@#?"
        index = brightness * (length asciiChars - 1) `div` 255
    in asciiChars !! index

imageToAscii :: Image PixelRGB8 -> Int -> Int -> String
imageToAscii img targetWidth targetHeight =
    let (width, height) = (imageWidth img, imageHeight img)
        stepX = width `div` targetWidth
        stepY = height `div` targetHeight
        getPixel x y = pixelAt img (x * stepX) (y * stepY)
        rows = [[ pixelToChar (getPixel x y) | x <- [0..targetWidth-1]] 
               | y <- [0..targetHeight-1]]
    in unlines rows

displayFrame :: String -> IO ()
displayFrame frame = do
    clearScreen
    setCursorPosition 0 0
    putStr frame
    hFlush stdout

main :: IO ()
main = do
    imgDir <- getDataFileName "badapple"
    files <- sort <$> listDirectory imgDir
    
    let imageFiles = filter (\f -> isSuffixOf ".png" f) files
    let frameDelay = 100000 
    let termWidth = 140  
    let termHeight = 44 

    forM_ imageFiles $ \file -> do
        let filePath = imgDir ++ "\\" ++ file
        imgResult <- readImage filePath
        case imgResult of
            Left err -> putStrLn $ "Error reading image: " ++ err
            Right img -> do
                let rgbImg = convertRGB8 img
                let asciiArt = imageToAscii rgbImg termWidth termHeight
                displayFrame asciiArt
                threadDelay frameDelay
