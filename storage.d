class Account
{
	string id,pass;

	this(string id, string pass)
	{
		this.id = id;
		this.pass = pass;
	}
}

__gshared synchronized Account[] accounts;

void initStorage()
{
	accounts ~= new Account("m1kc", "112");
	accounts ~= new Account("Solkin", "112");
}

bool accountExists(string id)
{
	foreach(Account a; accounts)
	{
		if (a.id==id) return true;
	}
	return false;
}

bool passwordIsValid(string id, string pass)
{
	foreach(Account a; accounts)
	{
		if ((a.id==id)&&(a.pass==pass)) return true;
	}
	return false;
}

void createAccount(string id, string pass)
{
	accounts ~= new Account(id, pass);
}

string getContactsAsIni(string id)
{
	return "[group1]
m1kc=m1kc
Solkin=Solkin
[group2]
Ku-Kluks-Klan=kkk
Упячка=upyachka
";

}

void addContact(string account, string id)
{
}

bool contactExists(string account, string id)
{
	return true;
}

void renameContact(string account, string id1, string id2)
{
}

void removeContact(string account, string id)
{
}

string getGroupsAsString(string account)
{
	return "group1|group2";
}

bool groupExists(string account, string groupName)
{
	return true;
}

void renameGroup(string account, string name1, string name2)
{
}

void removeGroup(string account, string groupName)
{
}
