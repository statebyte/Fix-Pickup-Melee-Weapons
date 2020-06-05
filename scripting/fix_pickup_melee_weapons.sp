#include <sdkhooks>
#include <sdktools>

//int m_hActiveWeapon = -1;
int m_hMyWeapons = -1;
int m_iItemDefinitionIndex = -1;

public Plugin myinfo = 
{
	name = "Fix Pickup Melee Weapons",
	author = "FIVE",
	description = "Fix Pickup Melee Weapons",
	version = "1.1",
	url = "https://hlmod.ru"
};

public void OnPluginStart()
{
	//m_hActiveWeapon = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	m_iItemDefinitionIndex = FindSendPropInfo("CEconEntity", "m_iItemDefinitionIndex");

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

Action OnWeaponCanUse(int iClient, int iWeapon)
{
	char sClassname[32];
	GetEdictClassname(iWeapon, sClassname, sizeof(sClassname));
	//PrintToChatAll("Пытаюсь поднять - %s", sClassname);

	if(sClassname[7] == 'k' || sClassname[7] == 'b' || (sClassname[7] == 'm' && sClassname[8] == 'e'))
	{
		if(!CheckWeapons(iClient, GetEntData(iWeapon, m_iItemDefinitionIndex, 2)))
		{
			//PrintToChatAll("Поднимаю %s....", sClassname);
			EquipPlayerWeapon(iClient, iWeapon);
			FakeClientCommand(iClient, "use %s", sClassname);
		}
		else
		{
			static int iTimeOut[MAXPLAYERS+1];
			int iTime = GetTime();
			if(iTimeOut[iClient] < iTime)
			{
				PrintHintText(iClient, "#Cstrike_Already_Own_Weapon");
				iTimeOut[iClient] = iTime + 4;
			}
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

bool CheckWeapons(int iClient, int iItemDefinitionIndex)
{
	int iWeaponEnt = -1;

	//int iMyWeapons = GetEntPropArraySize(iClient, Prop_Send, "m_hMyWeapons");
	for(int i = 0; i < 64; i++)
	{
		iWeaponEnt = GetEntDataEnt2(iClient, m_hMyWeapons+i*4);

		if(iWeaponEnt != -1 && (GetEntData(iWeaponEnt, m_iItemDefinitionIndex, 2) == iItemDefinitionIndex))
		{
			return true;
		}
	}

	return false;
}