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

<title>Log In Page</title>																																																																																																																																																																																																																																																																																																																																								
</head>

<body>

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
    
	    String name = request.getParameter("name");
		String age = request.getParameter("age");
		String role = request.getParameter("role");
		String state = request.getParameter("state");
		
		// check that all params good, then insert into database if user is unique
        if (name.length() > 0 && Integer.parseInt(age) > 0 && (role.equals("owner") || role.equals("customer"))) {
           
        	// Begin transaction
            conn.setAutoCommit(false);

            // Create the prepared statement and use it to INSERT 
            pstmt = conn
            .prepareStatement("INSERT INTO users (name,age,role,state) SELECT ?,?,?,? " + 
            "WHERE NOT EXISTS (SELECT name FROM users WHERE name = ?);");
            pstmt.setString(1, name);
            pstmt.setInt(2, Integer.parseInt(age));
            pstmt.setString(3, role);
            pstmt.setString(4, state);
            pstmt.setString(5, name);
                  
            int rows = pstmt.executeUpdate();
            
            if (rows == 0) {
            	%>Your sign up failed<%
            }
            else {
            	%>
            	You have successfully signed up. <p/>
            	Please log in below <p/>
            	<form action="home.jsp" method="GET">
					Name: <input type="text" name="name" size="20"/><p/>
					<button type="submit">Log In</button>
				</form>
            	<%
            }
            
                      
            // Commit transaction
            conn.commit();
            conn.setAutoCommit(true);
        }
        conn.close();
        
	} catch (SQLException e) {
		e.printStackTrace();
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




</body>
</html>