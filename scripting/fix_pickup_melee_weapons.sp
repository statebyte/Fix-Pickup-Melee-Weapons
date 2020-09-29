#include <sdkhooks>
#include <sdktools>

//int m_hActiveWeapon = -1;
int m_hMyWeapons = -1;
int m_iItemDefinitionIndex = -1;
static int g_iTimeOut[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "Fix Pickup Melee Weapons",
	author = "FIVE",
	description = "Fix Pickup Melee Weapons",
	version = "1.2",
	url = "https://hlmod.ru"
};

public void OnPluginStart()
{
	//m_hActiveWeapon = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	m_iItemDefinitionIndex = FindSendPropInfo("CEconEntity", "m_iItemDefinitionIndex");

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i))
	{
		OnClientPutInServer(i);
	}
}

void Event_RoundStart(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	for(int i; i <= MaxClients; i++) g_iTimeOut[i] = 0;
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
		int iTime = GetTime();
		if(g_iTimeOut[iClient] < iTime)
		{
			if(!CheckWeapons(iClient, GetEntData(iWeapon, m_iItemDefinitionIndex, 2)))
			{
				//PrintToChatAll("Поднимаю %s....", sClassname);
				EquipPlayerWeapon(iClient, iWeapon);
				FakeClientCommand(iClient, "use %s", sClassname);
				g_iTimeOut[iClient] = iTime + 2;
			}
			else
			{
				PrintHintText(iClient, "#Cstrike_Already_Own_Weapon");
				g_iTimeOut[iClient] = iTime + 4;
				return Plugin_Handled;
			}
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