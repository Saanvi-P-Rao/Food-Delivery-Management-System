package com.foodexpress;

import com.foodexpress.model.QueryResult;
import com.foodexpress.model.VisualQueryRequest;
import com.foodexpress.model.VisualQueryRequest.FilterCondition;
import com.foodexpress.model.VisualQueryRequest.SelectColumn;
import com.foodexpress.model.VisualQueryRequest.SortRule;
import com.foodexpress.service.SqlExecutionService;
import com.foodexpress.service.SqlExecutionService.ExecutionMode;
import com.foodexpress.service.VisualQueryBuilder;
import com.foodexpress.util.PasswordUtil;
import com.foodexpress.util.ValidationUtil;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class FoodExpressTest {

    @Test
    void testPasswordHashingAndSeedVerification() {
        String raw = "FoodExpress@123";
        String hashed = PasswordUtil.hashPassword(raw);
        assertTrue(PasswordUtil.verifyPassword(raw, hashed));
        assertFalse(PasswordUtil.verifyPassword("WrongPass", hashed));

        String seedHash = "pbkdf2:65536:1a2b3c4d5e6f708192a3b4c5d6e7f809:d22686eb9569de4f4724825bb7ec5c6a6efb0ffd7398f26255c3352facb702be";
        assertTrue(PasswordUtil.verifyPassword(raw, seedHash), "Seeded PBKDF2 hash must verify with PasswordUtil");
    }

    @Test
    void testValidationHelpers() {
        assertTrue(ValidationUtil.isValidEmail("aarav.sharma@example.in"));
        assertFalse(ValidationUtil.isValidEmail("not-an-email"));
        assertTrue(ValidationUtil.isValidPhone("9876543210"));
        assertTrue(ValidationUtil.isValidPincode("560038"));
        assertNotNull(ValidationUtil.parsePositiveDecimal("299.50"));
        assertNull(ValidationUtil.parsePositiveDecimal("-10"));
    }

    @Test
    void testVisualQueryBuilderGeneratesValidSql() {
        Map<String, List<String>> schema = Map.of(
            "Food_Items", List.of("food_id", "restaurant_id", "name", "category", "price", "is_veg", "is_available")
        );

        VisualQueryRequest req = new VisualQueryRequest();
        req.setTable("Food_Items");

        SelectColumn c1 = new SelectColumn();
        c1.setColumn("category");
        SelectColumn c2 = new SelectColumn();
        c2.setColumn("price");
        c2.setAggregate("AVG");
        c2.setAlias("avg_price");
        req.setColumns(List.of(c1, c2));

        FilterCondition f1 = new FilterCondition();
        f1.setColumn("is_veg");
        f1.setOperator("=");
        f1.setValue("true");

        FilterCondition f2 = new FilterCondition();
        f2.setConnector("OR");
        f2.setColumn("price");
        f2.setOperator("BETWEEN");
        f2.setValue("100");
        f2.setValue2("500");
        req.setFilters(List.of(f1, f2));

        req.setGroupBy(List.of("category"));

        SortRule sort = new SortRule();
        sort.setColumn("category");
        sort.setDirection("ASC");
        req.setOrderBy(List.of(sort));
        req.setLimit(50);

        VisualQueryBuilder builder = new VisualQueryBuilder();
        String sql = builder.buildSql(req, schema);

        assertTrue(sql.contains("SELECT `category`, AVG(`price`) AS `avg_price`"));
        assertTrue(sql.contains("FROM `Food_Items`"));
        assertTrue(sql.contains("WHERE `is_veg` = TRUE"));
        assertTrue(sql.contains("OR `price` BETWEEN 100 AND 500"));
        assertTrue(sql.contains("GROUP BY `category`"));
        assertTrue(sql.contains("ORDER BY `category` ASC"));
        assertTrue(sql.contains("LIMIT 50"));
    }

    @Test
    void testVisualQueryBuilderRejectsInvalidTableOrColumn() {
        Map<String, List<String>> schema = Map.of(
            "Users", List.of("user_id", "full_name", "email")
        );
        VisualQueryBuilder builder = new VisualQueryBuilder();

        VisualQueryRequest badTable = new VisualQueryRequest();
        badTable.setTable("NonExistentTable");
        assertThrows(IllegalArgumentException.class, () -> builder.buildSql(badTable, schema));

        VisualQueryRequest badCol = new VisualQueryRequest();
        badCol.setTable("Users");
        SelectColumn sc = new SelectColumn();
        sc.setColumn("password_hash; DROP TABLE Users");
        badCol.setColumns(List.of(sc));
        assertThrows(IllegalArgumentException.class, () -> builder.buildSql(badCol, schema));
    }

    @Test
    void testPublicExecutionSecurityPolicy() {
        SqlExecutionService service = new SqlExecutionService();

        QueryResult multi = service.executeQuery("SELECT 1; DROP TABLE Users", false, false, "test", "MANUAL", ExecutionMode.LANDING_PUBLIC);
        assertFalse(multi.isSuccess());
        assertEquals("MULTI_STATEMENT", multi.getStatementType());

        QueryResult dropRes = service.executeQuery("DROP TABLE Users", false, false, "test", "MANUAL", ExecutionMode.LANDING_PUBLIC);
        assertFalse(dropRes.isSuccess());
        assertTrue(dropRes.getErrorMessage().contains("Permission denied"));

        QueryResult sysRes = service.executeQuery("SELECT * FROM mysql.user", false, false, "test", "MANUAL", ExecutionMode.LANDING_PUBLIC);
        assertFalse(sysRes.isSuccess());
        assertTrue(sysRes.getErrorMessage().contains("Permission denied"));

        QueryResult delNoWhere = service.executeQuery("DELETE FROM Orders", false, false, "test", "MANUAL", ExecutionMode.LANDING_PUBLIC);
        assertFalse(delNoWhere.isSuccess());
        assertTrue(delNoWhere.isConfirmationRequired());
    }
}
