import std.stdio;
import std.file;
import std.string;
import std.array;

import inifile;

class Account
{
	string pass;
	string[string][string] contacts;

	this(string pass)
	{
		this.pass = pass;
	}
}

__gshared synchronized Account[string] accounts;

void initStorage()
{
	write("Reading storage... ");
	if (exists("msimd.db"))
	{
		foreach(string s; readText("msimd.db").splitLines())
		{
			string[] tmp = s.split("|");
			if (tmp[0]=="account")
			{
				accounts[tmp[1]] = new Account(tmp[2]);
			}
			else if (tmp[0]=="contact")
			{
				accounts[tmp[1]].contacts[tmp[2]][tmp[3]] = tmp[4];
			}
		}
		accounts.rehash();
		writeln("ok");
	}
	else
	{
		writeln("msimd.db was not found, skipped");
		// debug
		createAccount("m1kc", "112");
		addContact("m1kc", "m1kc", "m1kc", "group1");
		addContact("m1kc", "solkin", "Solkin", "group1");
		addContact("m1kc", "kkk", "Ku-Kluks-Klan", "group2");
		addContact("m1kc", "upyachka", "Упячка", "group2");
		createAccount("solkin", "112");
		addContact("solkin", "m1kc", "m1kc", "group1");
		addContact("solkin", "solkin", "Solkin", "group1");
		addContact("solkin", "kkk", "Ku-Kluks-Klan", "group2");
		addContact("solkin", "upyachka", "Упячка", "group2");
	}
}

void writeDB()
{
	// TODO: speed up
	synchronized
	{
		if (exists("msimd.db")) std.file.remove("msimd.db");
		foreach(string id, Account a; accounts)
		{
			append("msimd.db", "account|" ~ id ~ "|" ~ a.pass ~ "\n");
			foreach(groupName, group; a.contacts)
			{
				foreach(string name, string value; group)
				{
					append("msimd.db", "contact|" ~ id ~ "|" ~ groupName ~ "|" ~ name ~ "|" ~ value ~ "\n");
				}
			}
		}
	}
}

bool accountExists(string id)
{
	return ((id in accounts) !is null);
}

bool passwordIsValid(string id, string pass)
{
	//writeln("passwordIsValid() call");
	//writeln("test: ", (((id in accounts) !is null) && (accounts[id].pass == pass)) );
	//writeln("ok, returning...");
	//scope(exit) writeln("exit");
	return (((id in accounts) !is null) && (accounts[id].pass == pass));
}

void createAccount(string id, string pass)
{
	accounts[id] = new Account(pass);
	writeDB();
	writeln("Account created: " ~ id);
}

string getContactsAsIni(string id)
{
	Account a = accounts[id];
	scope IniFile i = new IniFile();
	foreach (string groupName, string[string] group; a.contacts)
	{
		foreach(string name, string id; group)
		{
			i.setItem(groupName, name, id);
		}
	}
	return i.serialize();
}

void addContact(string account, string id, string name, string group)
{
	accounts[account].contacts[group][name] = id;
	writeDB();
}

bool renameContact(string account, string id1, string id2)
{
	// TODO: fix protocol
	return true;
}

bool removeContact(string account, string id)
{
	// TODO: fix protocol
	return true;
}

string getGroupsAsString(string account)
{
	Account a = accounts[account];
	string result = "";
	foreach (string groupName; a.contacts.keys)
	{
		result ~= "|";
		result ~= groupName;
	}
	return result[1..$];
}

bool groupExists(string account, string groupName)
{
	return ((groupName in accounts[account].contacts) !is null);
}

bool renameGroup(string account, string name1, string name2)
{
	assert(name1 != name2);
	accounts[account].contacts[name2] = accounts[account].contacts[name1];
	accounts[account].contacts.remove(name1);
	writeDB();
	return true;
}

bool removeGroup(string account, string groupName)
{
	accounts[account].contacts.remove(groupName);
	writeDB();
	return true;
}
