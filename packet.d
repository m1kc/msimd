import std.stdio;
import std.stream;
import std.conv;

class Packet
{
	string from, to, type, content;

	this(string from, string to, string type, string content)
	{
		this.from = from;
		this.to = to;
		this.type = type;
		this.content = content;
	}

	override string toString()
	{
		return "" ~ from ~ " -> " ~ to ~ ": " ~ type ~ ": " ~ content;
	}
}

string readUTF(InputStream s)
{
	//write("Reading an utf... ");
	ubyte byte1,byte2;
	s.read(byte1);
	s.read(byte2);
	int len = byte1*256+byte2;
	//writeln(len);
	return to!string(s.readString(len));
}

Packet readPacket(string from, InputStream s)
{
	//writeln("Reading a packet.");
	Packet p = new Packet(from, readUTF(s), readUTF(s), readUTF(s));
	writeln(">>> ",p.toString());
	return p;
}

void writeUTF(string s, OutputStream os)
{
	ubyte byte1,byte2;
	byte1 = cast(ubyte)s.length/256;
	byte2 = s.length%256;
	os.write(byte1);
	os.write(byte2);
	os.writeString(s);
}

void writePacket(Packet p, OutputStream os)
{
	writeln(" << ",p.toString());
	writeUTF(p.from, os);
	writeUTF(p.type, os);
	writeUTF(p.content, os);
}
