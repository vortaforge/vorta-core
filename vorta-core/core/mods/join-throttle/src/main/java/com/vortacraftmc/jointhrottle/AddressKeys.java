package com.vortacraftmc.jointhrottle;

// AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.

import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Turns a connection's remote address into the key the limiter counts against.
 *
 * <p>IPv4 addresses are used as-is. IPv6 addresses are reduced to their /64
 * prefix: an IPv6 customer normally owns a whole /64, so keying on the full
 * 128-bit address would let one client dodge the limit by cycling through
 * addresses it already controls.
 */
public final class AddressKeys {

    private AddressKeys() {}

    /** @return the limiter key, or {@code null} if the address has no usable IP (then the caller must not throttle). */
    public static String keyFor(SocketAddress address) {
        if (address instanceof InetSocketAddress inet && inet.getAddress() != null) {
            return keyFor(inet.getAddress());
        }
        return null;
    }

    public static String keyFor(InetAddress address) {
        if (address instanceof Inet6Address) {
            byte[] raw = address.getAddress();
            StringBuilder sb = new StringBuilder("v6/");
            for (int i = 0; i < 8; i++) {
                sb.append(String.format("%02x", raw[i] & 0xff));
                if (i % 2 == 1 && i < 7) sb.append(':');
            }
            return sb.append("::/64").toString();
        }
        return address.getHostAddress();
    }

    private static final Pattern IPV4_LITERAL = Pattern.compile("\\d{1,3}(\\.\\d{1,3}){3}");
    private static final Pattern IPV6_LITERAL = Pattern.compile("[0-9a-fA-F:.]+(%[0-9A-Za-z_.\\-]+)?");

    /**
     * Normalizes an IP <em>literal</em> so different spellings of the same address compare equal: {@code ::1},
     * {@code 0:0:0:0:0:0:0:1} and {@code 0000:...:0001} all become {@code 0:0:0:0:0:0:0:1} (what
     * {@link InetAddress#getHostAddress()} returns), an IPv4-mapped IPv6 literal becomes its IPv4 form, and a
     * {@code %scope} suffix is dropped.
     *
     * <p>Anything that is not an IP literal (a hostname, junk) is returned trimmed and lower-cased, unchanged
     * otherwise. Never performs a DNS lookup: the text is only parsed when it already looks like a literal.
     */
    public static String canonicalLiteral(String text) {
        if (text == null) return "";
        String t = text.strip().toLowerCase(Locale.ROOT);
        int scope = t.indexOf('%');
        if (scope >= 0) t = t.substring(0, scope);
        boolean literal = IPV4_LITERAL.matcher(t).matches() || (t.indexOf(':') >= 0 && IPV6_LITERAL.matcher(t).matches());
        if (!literal) return t;
        try {
            String host = InetAddress.getByName(t).getHostAddress();
            int hostScope = host.indexOf('%');
            return (hostScope >= 0 ? host.substring(0, hostScope) : host).toLowerCase(Locale.ROOT);
        } catch (java.net.UnknownHostException | RuntimeException malformed) {
            return t;
        }
    }
}
