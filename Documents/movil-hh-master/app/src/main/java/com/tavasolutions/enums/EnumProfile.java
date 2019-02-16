package com.tavasolutions.enums;

public enum  EnumProfile {

    ADMIN(1),
    HOUSEKEEPING_MANAGER(2),
    MAITENANCE_MANAGER(3),
    FRONTDESK_MANAGER(4),
    LOBBY(5),
    MAINTENACE(6),
    FRONTDESK(7);


    private final int value;

    EnumProfile(final int newValue) {
        value = newValue;
    }

    public int getValue() { return value; }


}
