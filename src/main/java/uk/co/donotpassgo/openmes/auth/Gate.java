package uk.co.donotpassgo.openmes.auth;

import java.util.Set;

/**
 * Persona allow-lists matching ChrisMES layout.php roles.
 * Per-org GRANT/DENY profiles (F19-0011 full) come later.
 */
public final class Gate {
    public static final String USER_MANAGEMENT = "USER_MANAGEMENT";
    public static final String MASTER_DATA = "MASTER_DATA";
    public static final String PART_EDIT = "PART_EDIT";
    public static final String CONFIG_EDIT = "CONFIG_EDIT";
    public static final String ROUTING_EDIT = "ROUTING_EDIT";
    public static final String WO_CREATE = "WO_CREATE";
    public static final String OPERATOR = "OPERATOR";
    public static final String SUPERVISOR = "SUPERVISOR";

    private static final Set<String> IT = Set.of("IT_ADMIN");
    private static final Set<String> PART_READ = Set.of(
        "IT_ADMIN", "SUPERVISOR", "MFG_ENGINEER", "MFG_ENGINEER_SUP", "ENGINEER", "QUALITY_ENGINEER");
    private static final Set<String> ROUTING = Set.of(
        "IT_ADMIN", "MFG_ENGINEER", "MFG_ENGINEER_SUP");
    private static final Set<String> WO = Set.of("IT_ADMIN", "SUPERVISOR");
    private static final Set<String> SUP = Set.of("IT_ADMIN", "SUPERVISOR", "MFG_ENGINEER_SUP");

    private Gate() {}

    public static boolean allow(SessionUser u, String gate) {
        if (u == null) return false;
        String p = u.personaCode;
        return switch (gate) {
            case USER_MANAGEMENT, CONFIG_EDIT, MASTER_DATA -> IT.contains(p);
            case PART_EDIT -> PART_READ.contains(p);
            case ROUTING_EDIT -> ROUTING.contains(p);
            case WO_CREATE -> WO.contains(p);
            case SUPERVISOR -> SUP.contains(p);
            case OPERATOR -> true;
            default -> "IT_ADMIN".equals(p);
        };
    }
}
