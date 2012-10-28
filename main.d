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

__gshared Session[] connections;

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
	writeln("SPTA start");
	writeln("МЯУ : ",connections.length);
	foreach(Session s; connections)
	{
		writeln("SPTA: ",s.account);
		if (s.account==id)
		{
			writeln("SPTA send");
			writePacket(p, s.stream);
			writeln("SPTA sent");
		}
	}
	writeln("SPTA end");
}

void processPacket(Packet p, Session s)
{
	string[] tmp = split(p.content, "|");
	if (p.to=="SERVER")
	{
		if (p.type=="ping")
		{
			writePacket(new Packet("SERVER", s.account, "ping-response", ""), s.stream);
		}
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
				if (accountExists(login) && passwordIsValid(login, pass))
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
		else if (p.type=="register")
		{
			assert(tmp.length==2);
			string login = tmp[0];
			string pass = tmp[1];
			if (accountExists(login))
			{
				writePacket(new Packet("SERVER", s.account, "fail", "register"), s.stream);
			}
			else
			{
				createAccount(login, pass);
				writePacket(new Packet("SERVER", s.account, "success", "register"), s.stream);
			}
		}
		else if (p.type=="contacts-list")
		{
			writePacket(new Packet("SERVER", s.account, "contacts-list", getContactsAsIni(s.account)), s.stream);
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
