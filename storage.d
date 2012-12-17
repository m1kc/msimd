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
		// debug
		this.contacts["group1"]["m1kc"] = "m1kc";
		this.contacts["group1"]["solkin"] = "solkin";
		this.contacts["group2"]["Ku-Kluks-Klan"] = "kkk";
		this.contacts["group2"]["Упячка"] = "upyachka";
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
		}
		accounts.rehash();
		writeln("ok");
	}
	else
	{
		writeln("msimd.db was not found, skipped");
		// debug
		createAccount("m1kc", "112");
		createAccount("solkin", "112");
	}
}

void writeDB()
{
	synchronized
	{
		if (exists("msimd.db")) std.file.remove("msimd.db");
		foreach(string id, Account a; accounts)
		{
			append("msimd.db", "account|" ~ id ~ "|" ~ a.pass ~ "\n");
		}
	}
}

bool accountExists(string id)
{
	return ((id in accounts) !is null);
}

bool passwordIsValid(string id, string pass)
{
	writeln("passwordIsValid() call");
	writeln("test: ", (((id in accounts) !is null) && (accounts[id].pass == pass)) );
	writeln("ok, returning...");
	scope(exit) writeln("exit");
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
}

bool renameContact(string account, string id1, string id2)
{
	return true;
}

bool removeContact(string account, string id)
{
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
	return true;
}

bool renameGroup(string account, string name1, string name2)
{
	assert(name1 != name2);
	accounts[account].contacts[name2] = accounts[account].contacts[name1];
	accounts[account].contacts.remove(name1);
	return true;
}

bool removeGroup(string account, string groupName)
{
	accounts[account].contacts.remove(groupName);
	return true;
}
