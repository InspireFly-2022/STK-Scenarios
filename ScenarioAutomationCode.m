%% STK Automation Code for Earth Orbiting Satellite Missions
% Researcher: William Suffa 
% Last Updated: 1/6/2022  
% Topic: STK Automation for Quicker .sc or .vdf files 
% Resources:  
% STK - Matlab code snippets  
% https://help.agi.com/stkdevkit/index.htm#stkObjects/ObjModMatlabCodeSamples.htm
%% Preset Settings  

% Designate if you want the STK Application to open (true) or not (false) 
visibility = input('Enter in if you want the STK application to open (true) or not (false):');  

% Designate the Scenario Files name
scenarioName = input('Enter STK Scenario File name in single quotations ('') format:'); 

% Designate the Scenario time start period
startTime = input('Enter STK Scenario Start Time in quotations in the format of (1 Jan 2022 00:00:00.000):'); 

% Designate the Scenario time stop period
stopTime = input('Enter STK Scenario Stop Time in quotations in the format of (1 Jan 2022 00:00:00.000):'); 
%% Create an STK Scenario File 
% Create an instance of STK 
stkApplication = actxserver('STK12.Application'); 

% Allows the User to have control over the program 
stkApplication.UserControl = 1; 

% Application Visibility 
if visibility == true  
    stkApplication.Visible = 1; 
else 
    stkApplication.Visible = 0;
end   

% Get the IAgStkObjectRoot interface 
root = stkApplication.Personality2;

%Creates a new Scenario 
scenario = root.Children.New('eScenario', scenarioName');  

%Sets the necessary Time Period 
scenario.SetTimePeriod(startTime, stopTime); 

% Resets the Animation Start Time to the Start Time
try 
root.ExecuteCommand('Animate * Reset'); 
catch 
root.Rewind();   
end   
%% Create a new satellite object  
% Insert in the satellite name 
satName = input('Enter in the Satellite Name: ');
TLE = input('Using a TLE? (True or False)'); 

% Creates a new satellite object 
satellite = root.CurrentScenario.Children.New('eSatellite', satName); 

% Sets the Propagator Type 
% For more propagators: https://help.agi.com/stk/index.htm#stk/vehSat_orbitProp_choose.htm
% satellite.SetPropagatorType('ePropagatorJ2'); 

% Allows you to Set the Orbits Classical Elements 
keplerian = satellite.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical'); 
keplerian.SizeShapeType = 'eSizeShapeAltitude'; 
keplerian.LocationType = 'eLocationTrueAnomaly'; 
keplerian.Orientation.AscNodeType = 'eAscNodeLAN';  

% Set the classical elements values for the orbit 
keplerian.SizeShape.PerigeeAltitude = input('Enter the Perigee Altitude in km: '); %km
keplerian.SizeShape.ApogeeAltitude = input('Enter the Apogee Altitude in km: '); %km 
keplerian.Orientation.Inclination = input('Enter the Inclination in degrees: '); %degrees 
keplerian.Orientation.ArgOfPerigee = input('Enter the Argument of Perigee in degrees: '); %degrees 
keplerian.Orientation.AscNode.Value = input('Enter the Ascending Node in degrees: '); %degrees 

% Assign the values to the Satellite and Propagate 
satellite.Propagator.InitialState.Representation.Assign(keplerian); 
satellite.Propagator.Propagate;   
%% Create Earth and Sun Object in STK  
% Creates a new Earth Planet Object 
planet = scenario.Children.New('ePlanet', 'Earth'); 
planet.CommonTasks.SetPositionSourceCentralBody('Earth','eEphemJPLDE'); 

% Creates a new Sun object 
sun = scenario.Children.New('ePlanet', 'Sun'); 
sun.CommonTasks.SetPositionSourceCentralBody('Sun','eEphemJPLDE'); 