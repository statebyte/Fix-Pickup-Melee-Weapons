#include <sdkhooks>
#include <sdktools>

public Plugin myinfo = 
{
	name = "Fix Pickup Melee Weapons",
	author = "FIVE",
	description = "Fix Pickup Melee Weapons",
	version = "1.0",
	url = "https://hlmod.ru"
};

public void OnPluginStart()
{
	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
	{
		OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int iClient)
{
	if(!IsFakeClient(iClient))
	{
		SDKHook(iClient, SDKHook_WeaponCanUse, OnWeaponCanUse);
	}
}

public Action OnWeaponCanUse(int iClient, int iWeapon)
{
	char sClassname[32];
	GetEdictClassname(iWeapon, sClassname, sizeof(sClassname));
	//PrintToChatAll("Пытаюсь поднять - %s", sClassname);

	if(sClassname[7] == 'k' || sClassname[7] == 'b' || (sClassname[7] == 'm' && sClassname[8] == 'e'))
	{
		if(!CheckWeapons(iClient, iWeapon))
		{
			//PrintToChatAll("Поднимаю %s....", sClassname);
			EquipPlayerWeapon(iClient, iWeapon);
			FakeClientCommand(iClient, "use %s", sClassname);
		}
		else 
		{
			PrintCenterText(iClient, "У вас уже есть это оружие!");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

bool CheckWeapons(int iClient, int iWeapon)
{
	int iWeaponEnt = -1;

	int iMyWeapons = GetEntPropArraySize(iClient, Prop_Send, "m_hMyWeapons");
	for(int i = 0; i < iMyWeapons; i++)
	{
		iWeaponEnt = GetEntPropEnt(iClient, Prop_Send, "m_hMyWeapons", i);

		if(iWeaponEnt != -1)
		{
			char sClassname[32], sClassname2[32];
			GetEdictClassname(iWeapon, sClassname, sizeof(sClassname));
			GetEdictClassname(iWeaponEnt, sClassname2, sizeof(sClassname2));
			if(!strcmp(sClassname, sClassname2)) return true;
		}
		
	}

	return false;
}