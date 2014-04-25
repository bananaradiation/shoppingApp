<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.postgresql.*" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Products Page</title>
</head>

<body>
<table>
    <tr>
        <%    
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                // Registering Postgresql JDBC driver with the DriverManager
                Class.forName("org.postgresql.Driver");

                // Open a connection to the database using DriverManager
                conn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost/cse135?" +
                    "user=postgres&password=postgres");
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // INSERT student values INTO the students table.
                    pstmt = conn
                    .prepareStatement("INSERT INTO products (name, sku, category, price) VALUES (?, ?, ?, ?)");

                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("sku"));
                    pstmt.setString(3, request.getParameter("category"));
                    pstmt.setInt(4, Integer.parseInt(request.getParameter("price")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>
            
            <%-- -------- UPDATE Code -------- --%>
            <%
                // Check if an update is requested
                if (action != null && action.equals("update")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    pstmt = conn
                        .prepareStatement("UPDATE products SET name = ?, sku = ?, "
                            + "price = ?, category = ? WHERE ID = ?");

                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("sku"));
                    pstmt.setInt(3, Integer.parseInt(request.getParameter("price")));
                    pstmt.setString(4, request.getParameter("category"));
                    pstmt.setInt(5, Integer.parseInt(request.getParameter("ID")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>
            
            <%-- -------- DELETE Code -------- --%>
            <%
                // Check if a delete is requested
                if (action != null && action.equals("delete")) {

                    // Begin transaction
                    conn.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    pstmt = conn
                        .prepareStatement("DELETE FROM products WHERE id = ?");

                    pstmt.setInt(1, Integer.parseInt(request.getParameter("ID")));
                    int rowCount = pstmt.executeUpdate();

                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
                }
            %>

            <%-- -------- SELECT Statement Code -------- --%>
            <%
                // Create the statement
                Statement statement = conn.createStatement();

                // Use the created statement to SELECT
                // the student attributes FROM the Student table.
                rs = statement.executeQuery("SELECT * FROM products");
            %>
            
            <!-- Add an HTML table header row to format the results -->
            <table border="1">
            <tr>
                <th>ID</th>
                <th>name</th>
                <th>sku</th>
                <th>price</th>
                <th>category</th>
            </tr>

            <tr>
                <form action="/products.jsp" method="POST">
                    <input type="hidden" name="action" value="insert"/>
                    <th>&nbsp;</th>
                    <th><input value="" name="name" size="10"/></th>
                    <th><input value="" name="sku" size="15"/></th>
                    <th><input value="" name="price" size="15"/></th>
                    <th><input value="" name="category" size="15"/></th>
                    <th><input type="submit" value="Insert"/></th>
                </form>
            </tr>

            <%-- -------- Iteration Code -------- --%>
            <%
                // Iterate over the ResultSet
                while (rs.next()) {
            %>

            <tr>
                <form action="products.jsp" method="POST">
                    <input type="hidden" name="action" value="update"/>
                    <input type="hidden" name="ID" value="<%=rs.getInt("ID")%>"/>

                <%-- Get the id --%>
                <td>
                    <%=rs.getInt("ID")%>
                </td>

                <td>
                    <input value="<%=rs.getString("name")%>" name="name" size="15"/>
                </td>
				
				<td>
                    <input value="<%=rs.getString("sku")%>" name="sku" size="15"/>
                </td>

                <td>
                    <input value="<%=rs.getInt("price")%>" name="price" size="15"/>
                </td>

                <td>
                    <input value="<%=rs.getString("category")%>" name="category" size="15"/>
                </td>

                <%-- Button --%>
                <td><input type="submit" value="Update"></td>
                </form>
                <form action="products.jsp" method="POST">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" value="<%=rs.getInt("ID")%>" name="ID"/>
                    <%-- Button --%>
                <td><input type="submit" value="Delete"/></td>
                </form>
            </tr>

            <%
                }
            %>

            <%-- -------- Close Connection Code -------- --%>
            <%
                // Close the ResultSet
                rs.close();

                // Close the Statement
                statement.close();

                // Close the Connection
                conn.close();
            } catch (SQLException e) {

                // Wrap the SQL exception in a runtime exception to propagate
                // it upwards
                throw new RuntimeException(e);
            }
            finally {
                // Release resources in a finally block in reverse-order of
                // their creation

                if (rs != null) {
                    try {
                        rs.close();
                    } catch (SQLException e) { } // Ignore
                    rs = null;
                }
                if (pstmt != null) {
                    try {
                        pstmt.close();
                    } catch (SQLException e) { } // Ignore
                    pstmt = null;
                }
                if (conn != null) {
                    try {
                        conn.close();
                    } catch (SQLException e) { } // Ignore
                    conn = null;
                }
            }
            %>
        </table>
        </td>
    </tr>
</table>
</body>

</html>