//	@file Version: 1.0
//	@file Name: loadAdministratorMenu.sqf
//	@file Author: [404] Deadbeat
//	@file Created: 20/11/2012 05:19
//	@file Args:

#define adminMenu_option 50001
disableSerialization;

private ["_start","_panelOptions","_adminSelect","_displayAdmin"];

_uid = getPlayerUID player;

if ((_uid in Administrator)) then {
	_start = createDialog "AdminMenu";

	_displayAdmin = uiNamespace getVariable "AdminMenu";
	_adminSelect = _displayAdmin displayCtrl adminMenu_option;

	_panelOptions = [
		"Player Menu",
		"Vehicle Management",
		"Tags",
		"Teleport",
		"Money",
		"Access Proving Grounds",
		"Delete Food | Water"
	];

	{
		_adminSelect lbAdd _x;
	} forEach _panelOptions;
} else {
  exit;  
};