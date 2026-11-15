package com.foodexpress.util;

import java.math.BigDecimal;
import java.util.regex.Pattern;

/**
 * Input validation and sanitization helpers.
 */
public final class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9+\\-\\s]{8,15}$");
    private static final Pattern PINCODE_PATTERN = Pattern.compile("^[0-9]{5,10}$");

    private ValidationUtil() {
    }

    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static String trimOrEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        return phone != null && PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    public static boolean isValidPincode(String pincode) {
        return pincode != null && PINCODE_PATTERN.matcher(pincode.trim()).matches();
    }

    public static int parsePositiveInt(String value, int fallback) {
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : fallback;
        } catch (Exception e) {
            return fallback;
        }
    }

    public static BigDecimal parsePositiveDecimal(String value) {
        if (isBlank(value)) return null;
        try {
            BigDecimal bd = new BigDecimal(value.trim());
            return bd.compareTo(BigDecimal.ZERO) > 0 ? bd : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
