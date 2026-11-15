package com.foodexpress.util;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * JSON serialization helper backed by Gson.
 */
public final class JsonUtil {

    private static final Gson GSON = new GsonBuilder()
        .setDateFormat("yyyy-MM-dd HH:mm:ss")
        .serializeNulls()
        .create();

    private JsonUtil() {
    }

    public static Gson gson() {
        return GSON;
    }

    public static void writeJson(HttpServletResponse resp, int statusCode, Object payload) throws IOException {
        resp.setStatus(statusCode);
        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(GSON.toJson(payload));
    }
}
