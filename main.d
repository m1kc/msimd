import core.thread;
import std.array;
import std.stdio;
import std.conv;
import std.string;
import std.getopt;
import std.socket;
import std.socketstream;
import std.stream;
import std.random;
import packet, storage;

__gshared synchronized Session[] connections;

void main(string[] args)
{
	writeln("msimd 1.0");

	ushort port = 3215;
	getopt(args, "port|p", &port);
	writeln("Using port ",port);

	initStorage();

	write("Starting server... ");
	Socket server = new TcpSocket();
	assert(server.isAlive);
	server.bind(new InternetAddress(port));
	server.listen(10);
	scope(exit) server.close();
	writeln("ok");

	while(true)
	{
		Socket s = server.accept();
		writeln("Client connected: ",s.remoteAddress().toString());
		Session session = new Session(s);
		connections ~= [session];
		session.start();
	}
}

void sendPacketToAccount(Packet p, string id)
{
	foreach(Session s; connections)
	{
		if (s.account==id)
		{
			writePacket(p, s.stream);
		}
	}
}

bool loginIsValid(string login)
{
	if (login=="SERVER") return false;
	foreach(char c; login)
	{
		if ( ((c>='a')&&(c<='z')) || ((c>='0')&&(c<='9')) || (c=='-') || (c=='_') ) continue; else return false;
	}
	if (login[0]=='-' || login[$-1]=='-' || login[0]=='_' || login[$-1]=='_') return false;
	return true;
}
unittest
{
	assert(loginIsValid("m1kc"));
	assert(loginIsValid("solkin"));
	assert(loginIsValid("sunduk-trava"));
	assert(loginIsValid("well_done"));
	assert(!loginIsValid("_m1kc"));
	assert(!loginIsValid("-m1kc"));
	assert(!loginIsValid("m1kc_"));
	assert(!loginIsValid("m1kc-"));
}

void processPacket(Packet p, Session s)
{
	string[] tmp = split(p.content, "|");
	if (p.to=="SERVER")
	{
		// ping
		if (p.type=="ping")
		{
			writePacket(new Packet("SERVER", s.account, "ping-response", ""), s.stream);
		}
		// auth
		else if (p.type=="auth")
		{
			assert(tmp.length==2);
			string login = tmp[0];
			string pass = tmp[1];
			if (s.loggedIn)
			{
				writePacket(new Packet("SERVER", s.account, "wtf", "auth"), s.stream);
			}
			else
			{
				if (passwordIsValid(login, pass))
				{
					s.account = login;
					s.loggedIn = true;
					writePacket(new Packet("SERVER", s.account, "success", "auth"), s.stream);
				}
				else
				{
					writePacket(new Packet("SERVER", s.account, "fail", "auth"), s.stream);
				}
			}
		}
		// register
		else if (p.type=="register")
		{
			assert(tmp.length==2);
			string login = tmp[0];
			string pass = tmp[1];
			if (accountExists(login) || !loginIsValid(login))
			{
				writePacket(new Packet("SERVER", s.account, "fail", "register"), s.stream);
			}
			else
			{
				createAccount(login, pass);
				writePacket(new Packet("SERVER", s.account, "success", "register"), s.stream);
			}
		}
		// contacts-list
		else if (p.type=="contacts-list")
		{
			writePacket(new Packet("SERVER", s.account, "contacts-list", getContactsAsIni(s.account)), s.stream);
		}
		// contacts-add
		else if (p.type=="contacts-add")
		{
			assert(tmp.length==3);
			addContact(s.account, tmp[0], tmp[1], tmp[2]);
			writePacket(new Packet("SERVER", s.account, "success", "contacts-add"), s.stream);
		}
		// contacts-rename
		else if (p.type=="contacts-rename")
		{
			assert(tmp.length==2);
			string id1 = tmp[0];
			string id2 = tmp[1];
			if (renameContact(s.account, id1, id2))
			{
				writePacket(new Packet("SERVER", s.account, "success", "contacts-rename"), s.stream);
			}
			else
			{
				writePacket(new Packet("SERVER", s.account, "fail", "contacts-rename"), s.stream);
			}
		}
		// contacts-remove
		else if (p.type=="contacts-remove")
		{
			if (removeContact(s.account, p.content))
			{
				writePacket(new Packet("SERVER", s.account, "success", "contacts-remove"), s.stream);
			}
			else
			{
				writePacket(new Packet("SERVER", s.account, "fail", "contacts-remove"), s.stream);
			}
		}
		// contacts-groups-list
		else if (p.type=="contacts-groups-list")
		{
			writePacket(new Packet("SERVER", s.account, "contacts-groups-list", getGroupsAsString(s.account)), s.stream);
		}
		// contacts-groups-rename
		else if (p.type=="contacts-groups-rename")
		{
			assert(tmp.length==2);
			string name1 = tmp[0];
			string name2 = tmp[1];
			if (renameGroup(s.account, name1, name2))
			{
				writePacket(new Packet("SERVER", s.account, "success", "contacts-groups-rename"), s.stream);
			}
			else
			{
				writePacket(new Packet("SERVER", s.account, "fail", "contacts-groups-rename"), s.stream);
			}
		}
		// contacts-groups-remove
		else if (p.type=="contacts-groups-remove")
		{
			if (removeGroup(s.account, p.content))
			{
				writePacket(new Packet("SERVER", s.account, "success", "contacts-groups-remove"), s.stream);
			}
			else
			{
				writePacket(new Packet("SERVER", s.account, "fail", "contacts-groups-remove"), s.stream);
			}
		}
	}
	else
	{
		sendPacketToAccount(p, p.to);
	}
}

class Session : Thread
{
	this(Socket s)
	{
		this.socket = s;
		this.stream = new SocketStream(s);
		this.uid = uniform(0, long.max);
		this.account = "temp$" ~ to!string(this.uid);
		super( &run );
	}

private:
	Socket socket;
	SocketStream stream;
	long uid;
	string account;
	bool loggedIn = false;

	void run()
	{
		while(true)
		{
			processPacket(readPacket(this.account, stream), this);
		}
	}
}
