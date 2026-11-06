package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import static org.junit.jupiter.api.Assertions.*;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import org.junit.jupiter.api.Test;

class AddressKeysTest {

    private static InetAddress v6(String hex32) throws Exception {
        byte[] b = new byte[16];
        for (int i = 0; i < 16; i++) b[i] = (byte) Integer.parseInt(hex32.substring(i * 2, i * 2 + 2), 16);
        return InetAddress.getByAddress(b);
    }

    @Test void ipv4IsUsedAsIs() throws Exception {
        assertEquals("203.0.113.7", AddressKeys.keyFor(InetAddress.getByAddress(new byte[]{(byte) 203, 0, 113, 7})));
    }

    @Test void ipv6AddressesInTheSame64ShareAKey() throws Exception {
        InetAddress a = v6("20010db8000100020000000000000001");
        InetAddress b = v6("20010db800010002ffffffffffffffff");
        assertEquals(AddressKeys.keyFor(a), AddressKeys.keyFor(b));
    }

    @Test void ipv6AddressesInDifferent64sDiffer() throws Exception {
        InetAddress a = v6("20010db8000100020000000000000001");
        InetAddress b = v6("20010db8000100030000000000000001");
        assertNotEquals(AddressKeys.keyFor(a), AddressKeys.keyFor(b));
    }

    @Test void socketAddressWithoutAUsableIpGivesNull() {
        assertNull(AddressKeys.keyFor(InetSocketAddress.createUnresolved("example.invalid", 25565)));
        assertNull(AddressKeys.keyFor((java.net.SocketAddress) null));
    }

    @Test void canonicalLiteralMakesIpv6SpellingsEqual() {
        String loopback = AddressKeys.canonicalLiteral("0:0:0:0:0:0:0:1");
        assertEquals(loopback, AddressKeys.canonicalLiteral("::1"));
        assertEquals(loopback, AddressKeys.canonicalLiteral("0000:0000:0000:0000:0000:0000:0000:0001"));
        assertEquals(loopback, AddressKeys.canonicalLiteral("  ::1  "));
        assertEquals(AddressKeys.canonicalLiteral("FE80::1"), AddressKeys.canonicalLiteral("fe80:0:0:0:0:0:0:1"));
    }

    @Test void canonicalLiteralDropsScopeId() {
        assertEquals(AddressKeys.canonicalLiteral("fe80::1"), AddressKeys.canonicalLiteral("fe80::1%eth0"));
    }

    @Test void canonicalLiteralUnwrapsIpv4MappedAndKeepsIpv4() {
        assertEquals("203.0.113.7", AddressKeys.canonicalLiteral("::ffff:203.0.113.7"));
        assertEquals("203.0.113.7", AddressKeys.canonicalLiteral("203.0.113.7"));
    }

    @Test void canonicalLiteralNeverResolvesHostnamesOrCrashesOnJunk() {
        assertEquals("example.invalid", AddressKeys.canonicalLiteral("Example.Invalid"));
        assertEquals("999.1.1.1", AddressKeys.canonicalLiteral("999.1.1.1"));
        assertEquals("", AddressKeys.canonicalLiteral(null));
        assertEquals("gggg::1", AddressKeys.canonicalLiteral("GGGG::1"));
    }
}
