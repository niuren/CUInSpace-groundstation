CREATE TABLE Payload_UAV_Telemetry (
        Packet_Count INTEGER NOT NULL,
	GPS_Data INTEGER NOT NULL,
        Altitude REAL NOT NULL,
        Pressure REAL NOT NULL,
        Temperature REAL NOT NULL,
        Airspeed REAL NOT NULL,
        Attitude_Real REAL NOT NULL,
        Attitude_I REAL NOT NULL,
        Attitude_J REAL NOT NULL,
        Attitude_K REAL NOT NULL,
        Battery_Voltage REAL NOT NULL,
        State INTEGER NOT NULL,
        FOREIGN KEY(GPS_Data) REFERENCES GPS(FrameID)
);
CREATE TABLE GPS (
        FrameID INTEGER PRIMARY KEY,
        GPS_Time TEXT NOT NULL,
        Latitude REAL NOT NULL,
        Longitude REAL NOT NULL,
        Speed REAL NOT NULL,
        Course REAL NOT NULL,
        Mission_Time INTEGER NOT NULL
);
CREATE TABLE Payload_Container_Telemetry (
        Packet_Count INTEGER NOT NULL,
	GPS_Data INTEGER NOT NULL,
        Altitude REAL NOT NULL,
        Pressure REAL NOT NULL,
        Temperature REAL NOT NULL,
        Battery_Voltage REAL NOT NULL,
        Deployed_Byte INTEGER NOT NULL,
        State INTEGER NOT NULL,
        FOREIGN KEY(GPS_Data) REFERENCES GPS(FrameID)
);
CREATE TABLE Rocket_Telemetry (
        Mission_Time INTEGER NOT NULL,
        Capacitor_Voltage REAL NOT NULL,
        Battery_Voltage REAL NOT NULL,
        Battery_Temp REAL NOT NULL,
        Ambient_Temp REAL NOT NULL,
        State TEXT NOT NULL,
        E_Match_1_Present INTEGER NOT NULL,
        E_Match_2_Present INTEGER NOT NULL,
        Parachute_Deployed INTEGER NOT NULL,
        Acceleration_X REAL NOT NULL,
        Acceleration_Y REAL NOT NULL,
        Acceleration_Z REAL NOT NULL,
        Pitch_Rate REAL NOT NULL,
        Roll_Rate REAL NOT NULL,
        Yaw_Rate REAL NOT NULL,
        Gyro_Temp INTEGER NOT NULL,
        Altitude REAL NOT NULL,
        Alt_Temp REAL NOT NULL,
        GPS_Data INTEGER,
        FOREIGN KEY(GPS_Data) REFERENCES GPS(FrameID)
);
