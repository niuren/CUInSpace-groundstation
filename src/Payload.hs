{-# LANGUAGE OverloadedStrings, RecordWildCards #-}
module Payload (
    ContainerFrame,
    PayloadFrame,
    containerFrame,
    payloadFrame,
    writeContainerFrame,
    writePayloadFrame
) where

import Data.Monoid ((<>))
import Data.Serialize.Get (Get, getWord8, getWord16le)
import Data.Serialize.IEEE754 (getFloat32le)
import Data.Text (pack)
import Data.Time (picosecondsToDiffTime, timeToTimeOfDay)
import Data.Word (Word8, Word16)
import Database.SQLite.Simple (Connection, NamedParam(..), executeNamed)
import Linear.Quaternion (Quaternion(..))
import Linear.V3 (V3(..))

import Rocket (GpsData(..), writeGpsData)

-- FIXME: what is the endianness of the multibyte quatities in the payload data?
-- Why is the time since midnight measured in milliSiemens?
-- What are the units of mission time?
-- What do vehicle and packet count mean?
-- Order of quaternion components?

data ContainerFrame = ContainerFrame {
    conVehicle :: Word8,
    conPacket :: Word16,
    conGpsData :: GpsData,
    conAltitude :: Float,
    conPressure :: Float,
    conTemperature :: Float,
    conBatteryVoltage :: Float,
    conDeployedByte :: Word8,
    conStateByte :: Word8
}

data PayloadFrame = PayloadFrame {
    paylVehicle :: Word8,
    paylPacket :: Word16,
    paylGpsData :: GpsData,
    paylAltitude :: Float,
    paylPressure :: Float,
    paylTemperature :: Float,
    paylAirspeed :: Float,
    paylAttitude :: Quaternion Float,
    paylBatteryVoltage :: Float,
    paylStateByte :: Word8
}

containerFrame :: Get ContainerFrame
containerFrame = do
    conVehicle <- getWord8
    conPacket <- getWord16le
    conGpsData <- getGpsData
    conAltitude <- getFloat32le
    conPressure <- getFloat32le
    conTemperature <- getFloat32le
    conBatteryVoltage <- getFloat32le
    conDeployedByte <- getWord8
    conStateByte <- getWord8
    return $ ContainerFrame {..}

payloadFrame :: Get PayloadFrame
payloadFrame = do
    paylVehicle <- getWord8
    paylPacket <- getWord16le
    paylGpsData <- getGpsData
    paylAltitude <- getFloat32le
    paylPressure <- getFloat32le
    paylTemperature <- getFloat32le
    paylAirspeed <- getFloat32le
    e <- getFloat32le
    i <- getFloat32le
    j <- getFloat32le
    k <- getFloat32le
    let paylAttitude = Quaternion e (V3 i j k)
    paylBatteryVoltage <- getFloat32le
    paylStateByte <- getWord8
    return $ PayloadFrame {..}

getGpsData :: Get GpsData
getGpsData = do
    utcTime <- fmap (timeToTimeOfDay . picosecondsToDiffTime . round . (1e6 *)) getFloat32le
    latitude <- fmap realToFrac getFloat32le
    longitude <- fmap fromIntegral getWord16le
    groundSpeed <- fmap fromIntegral getWord16le
    course <- fmap fromIntegral getWord16le
    missionTimeCollected <- fmap round getFloat32le
    return $ GpsData {..}

writeContainerFrame :: ContainerFrame -> Connection -> IO ()
writeContainerFrame (ContainerFrame {..}) conn = do
    rid <- writeGpsData conGpsData conn
    executeNamed conn conQuery [
        ":v" := conVehicle,
        ":pc" := conPacket,
        ":alt" := conAltitude,
        ":p" := conPressure,
        ":t" := conTemperature,
        ":bv" := conBatteryVoltage,
        ":d" := conDeployedByte,
        ":st" := conStateByte,
        ":rid" := rid]
  where conQuery = "INSERT INTO Rocket_Telemetry " <>
            "(Vehicle, Packet_Count, GPS_Data, Altitude, Pressure, Temperature, " <>
            "Battery_Voltage, Deployed_Byte, State) " <>
            "SELECT :v, :pc, FrameID, :alt, :p, :t, :bv, :d, :st " <>
            "FROM GPS WHERE rowid == :rid;"

writePayloadFrame :: PayloadFrame -> Connection -> IO ()
writePayloadFrame (PayloadFrame {..}) conn = do
    let Quaternion r (V3 i j k) = paylAttitude
    rid <- writeGpsData paylGpsData conn
    executeNamed conn conQuery [
        ":v" := paylVehicle,
        ":pc" := paylPacket,
        ":alt" := paylAltitude,
        ":p" := paylPressure,
        ":t" := paylTemperature,
        ":vair" := paylAirspeed,
        ":r" := r,
        ":i" := i,
        ":j" := j,
        ":k" := k,
        ":bv" := paylBatteryVoltage,
        ":st" := paylStateByte,
        ":rid" := rid]
  where conQuery = "INSERT INTO Rocket_Telemetry " <>
            "(Vehicle, Packet_Count, GPS_Data, Altitude, Pressure, Temperature, " <>
            "Airspeed, Attitude_Real, Attitude_I, Attitude_J, Attitude_K, " <>
            "Battery_Voltage, State) " <>
            "SELECT :v, :pc, FrameID, :alt, :p, :t, :vair, :r, :i, :j, :k, :bv, :st " <>
            "FROM GPS WHERE rowid == :rid;"
