//	@file Version: 1.0
//	@file Name: onKilled.sqf
//	@file Author: [404] Deadbeat
//	@file Created: 20/11/2012 05:19
//	@file Args:

// ///////////////////////
// // Hellop Vars Added //
// ///////////////////////
_tmpVeh = _tmpArr select 0;
_player = (_this select 0) select 0;
_killer = (_this select 0) select 1;

_tmpArr = nearestObjects [_player, ["LandVehicle"], 6];  //Execute this ASAP.

if(isnil {_player getVariable "cmoney"}) then {_player setVariable["cmoney",0,true];};

PlayerCDeath = [_player];
publicVariable "PlayerCDeath";
if (isServer) then {
	_id = PlayerCDeath spawn serverPlayerDied; 
};

if(!local _player) exitwith {};

// ///////////////
// //// BEGIN ////
// ///////////////
// Author: hellop
// Now we add a script to detect who killed the player by vehicle

//Dunno who killed
if ((isNull _killer)) then {
        player globalchat format["%1 died mysteriously.", name (_player)];
} else {
	//_killer Not null 
	if (_killer == _player) then {	
			_arrSize = count _tmpArr;
			if (_arrSize > 0) then {
					for [{_x=0},{_x<_arrSize},{_x=_x+1}] do {
							_killer = driver (_tmpArr select _x);
							if (isPlayer _killer) then {_x = _arrSize};  //break from for loop
					};
			};
			//Didn't find a driver
			if ((isNull _killer) or (_killer == _player)) then {
					player globalchat format["%1 died mysteriously.", name (_player)];
			}
			else {
					player globalchat format["%1 was run over by %2.", name (_player), name (_killer)];		
			};
	};
};
_player removeAllEventHandlers "killed";

// ///////////////
// ///// END /////
// ///////////////

if((_player != _killer) && (vehicle _player != vehicle _killer) && (playerSide == side _killer) && (str(playerSide) in ["WEST", "EAST"])) then {
	pvar_PlayerTeamKiller = objNull;
	if(_killer isKindOf "CAManBase") then {
		pvar_PlayerTeamKiller = _killer;
	} else {
		_veh = (_killer);
		_trts = configFile >> "CfgVehicles" >> typeof _veh >> "turrets";
		_paths = [[-1]];
		if (count _trts > 0) then {
			for "_i" from 0 to (count _trts - 1) do {
				_trt = _trts select _i;
				_trts2 = _trt >> "turrets";
				_paths = _paths + [[_i]];
				for "_j" from 0 to (count _trts2 - 1) do {
					_trt2 = _trts2 select _j;
					_paths = _paths + [[_i, _j]];
				};
			};
		};
		_ignore = ["SmokeLauncher", "FlareLauncher", "CMFlareLauncher", "CarHorn", "BikeHorn", "TruckHorn", "TruckHorn2", "SportCarHorn", "MiniCarHorn", "Laserdesignator_mounted"];
		_suspects = [];
		{
			_weps = (_veh weaponsTurret _x) - _ignore;
			if(count _weps > 0) then {
				_unt = objNull;
				if(_x select 0 == -1) then {_unt = driver _veh;}
				else {_unt = _veh turretUnit _x;};
				if(!isNull _unt) then {
					_suspects = _suspects + [_unt];
				};
			};
		} forEach _paths;

		if(count _suspects == 1) then {
			pvar_PlayerTeamKiller = _suspects select 0;
		};
	};
};

if(!isNull(pvar_PlayerTeamKiller)) then {
	publicVar_teamkillMessage = pvar_PlayerTeamKiller;
	publicVariable "publicVar_teamkillMessage";
};

private["_a","_b","_c","_d","_e","_f","_m","_to_delete"];

_to_delete = [];
_to_delete_quick = [];

if((_player getVariable "cmoney") > 0) then {
	_m = "EvMoney" createVehicle (position _player);
	_m setVariable["money", (_player getVariable "cmoney"), true];
	_m setVariable ["owner", "world", true];
	_to_delete = _to_delete + [_m];
};

if((_player getVariable "medkits") > 0) then {
	for "_a" from 1 to (_player getVariable "medkits") do {	
		_m = "CZ_VestPouch_EP1" createVehicle (position _player);
		_to_delete = _to_delete + [_m];
	};
};

if((_player getVariable "repairkits") > 0) then {
	for "_b" from 1 to (_player getVariable "repairkits") do {	
		_m = "Suitcase" createVehicle (position _player);
		_to_delete = _to_delete + [_m];
	};
};

publicVar_objectsToDelete = [_to_delete, _to_delete_quick];
publicVariableServer "publicVar_objectsToDelete";

true spawn {
	waitUntil {playerRespawnTime < 2};
	titleText ["", "BLACK OUT", 1];
};