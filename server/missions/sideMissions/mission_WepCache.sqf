//	@file Version: 1.0
//	@file Name: mission_WepCache.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy
//	@file Created: 08/12/2012 15:19
//	@file Args:

#include "sideMissionDefines.sqf";

if(!isServer) exitwith {};

private ["_result","_missionMarkerName","_missionType","_startTime","_returnData","_randomPos","_randomIndex","_vehicleClass","_box","_box2","_picture","_vehicleName","_hint","_currTime","_playerPresent","_unitsAlive"];

//Mission Initialization.
_result = 0;
_missionMarkerName = "WeaponCache_Marker";
_missionType = "Weapon Cache";
_startTime = floor(time);

diag_log format["WASTELAND SERVER - Side Mission Started: %1",_missionType];

//Get Mission Location
_returnData = call createMissionLocation;
_randomPos = _returnData select 0;
_randomIndex = _returnData select 1;

diag_log format["WASTELAND SERVER - Side Mission Waiting to run: %1",_missionType];
[sideMissionDelayTime] call createWaitCondition;
diag_log format["WASTELAND SERVER - Side Mission Resumed: %1",_missionType];

[_missionMarkerName,_randomPos,_missionType] call createClientMarker;

_box = createVehicle ["RULaunchersBox",[(_randomPos select 0), (_randomPos select 1),0],[], 0, "NONE"];
[_box,"mission_Side_USLaunchers"] call fn_refillbox;

_box2 = createVehicle ["RUSpecialWeaponsBox",[(_randomPos select 0), (_randomPos select 1) - 10,0],[], 0, "NONE"];
[_box2,"mission_Side_USSpecial"] call fn_refillbox;

_hint = parseText format ["<t align='center' color='%2' shadow='2' size='1.75'>Side Objective</t><br/><t align='center' color='%2'>------------------------------</t><br/><t align='center' color='%3' size='1.25'>%1</t><br/><t align='center' color='%3'>A supply drop has been spotted near the marker</t>", _missionType,  sideMissionColor, subTextColor];
[nil,nil,rHINT,_hint] call RE;

CivGrpS = createGroup civilian;
[CivGrpS,_randomPos] spawn createSmallGroup;

diag_log format["WASTELAND SERVER - Side Mission Waiting to be Finished: %1",_missionType];
_startTime = floor(time);
waitUntil
{
    sleep 1; 
	_playerPresent = false;
    _currTime = floor(time);
    if(_currTime - _startTime >= sideMissionTimeout) then {_result = 1;};
    {if((isPlayer _x) AND (_x distance _box <= missionRadiusTrigger)) then {_playerPresent = true};}forEach playableUnits;
    _unitsAlive = ({alive _x} count units CivGrpS);
    (_result == 1) OR ((_playerPresent) AND (_unitsAlive < 1)) OR ((damage _box) == 1)
};

if(_result == 1) then
{
	//Mission Failed.
    deleteVehicle _box;
    deleteVehicle _box2;
    {deleteVehicle _x;}forEach units CivGrps;
    deleteGroup CivGrpS;
    _hint = parseText format ["<t align='center' color='%2' shadow='2' size='1.75'>Objective Failed</t><br/><t align='center' color='%2'>------------------------------</t><br/><t align='center' color='%2' size='1.25'>%1</t><br/><t align='center' color='%3'>Objective failed, better luck next time</t>", _missionType, failMissionColor, subTextColor];
	[nil,nil,rHINT,_hint] call RE;
    diag_log format["WASTELAND SERVER - Side Mission Failed: %1",_missionType];
} else {
	//Mission Complete.
    deleteGroup CivGrpS;
    _hint = parseText format ["<t align='center' color='%2' shadow='2' size='1.75'>Objective Complete</t><br/><t align='center' color='%2'>------------------------------</t><br/><t align='center' color='%3' size='1.25'>%1</t><br/><t align='center' color='%3'>The ammo caches have been collected well done team</t>", _missionType, successMissionColor, subTextColor];
	[nil,nil,rHINT,_hint] call RE;
    diag_log format["WASTELAND SERVER - Side Mission Success: %1",_missionType];
};

//Reset Mission Spot.
MissionSpawnMarkers select _randomIndex set[1, false];
[_missionMarkerName] call deleteClientMarker;