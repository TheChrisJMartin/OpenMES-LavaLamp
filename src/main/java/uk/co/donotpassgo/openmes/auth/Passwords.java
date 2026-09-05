package uk.co.donotpassgo.openmes.auth;

import at.favre.lib.crypto.bcrypt.BCrypt;

/** PHP password_verify compatible ($2y$ / $2a$ / $2b$). Cost 12. */
public final class Passwords {
    private Passwords() {}

    public static String hash(String plain) {
        return BCrypt.withDefaults().hashToString(12, plain.toCharArray());
    }

    public static boolean verify(String plain, String hash) {
        if (plain == null || hash == null || hash.isBlank()) return false;
        BCrypt.Result r = BCrypt.verifyer().verify(plain.toCharArray(), hash);
        return r.verified;
    }
}
