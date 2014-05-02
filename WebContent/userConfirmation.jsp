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

<title>Confirm Product Insert</title>
</head>

<body>

<%
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
Statement st = null;

try {
	String name = (String)session.getAttribute("sessionName");
	String productName = request.getParameter("productName");
	String sku = request.getParameter("sku");
	String productCategoryName = request.getParameter("productCategory");
	String priceString = request.getParameter("price");
	float price = Float.parseFloat(priceString) > 0 ? Float.parseFloat(priceString) : -100;  

	// Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost/cse135?" +
        "user=postgres&password=postgres");
    
		// Start transaction
	    conn.setAutoCommit(false);

		pstmt = conn.prepareStatement("SELECT categories.ID FROM categories WHERE name = ?");
		pstmt.setString(1, productCategoryName);
		rs = pstmt.executeQuery();
		rs.next();
		int productCategory = Integer.parseInt(rs.getString("ID"));
		
	    pstmt = conn
	    .prepareStatement("INSERT INTO products (name, sku, category, price) VALUES (?, ?, ?, ?)");
	    	    
	    pstmt.setString(1, productName);
	    pstmt.setString(2, sku);
	    pstmt.setInt(3, productCategory);
	    pstmt.setFloat(4, price);
	    int rowCount = pstmt.executeUpdate();
	    
	    if (rowCount > 0) { 
		    conn.commit();
		    conn.setAutoCommit(true);
		    // End Transaction
	    } %>
	    
	Hello <%= name %> <p/>    
	    
	You have just submitted the following<p/>
	Product name: <%= productName%> <p/>
	Product sku:  <%= sku%> <p/>
	Product category:  <%= productCategoryName%> <p/>
	Product price:  <%= price%> <p/>
	<a href="products.jsp?category=all">Click here to go back to Products</a>	    
<%	    
}
catch (SQLException e) { 
	%>
	Failure to insert new product<p/>
	<a href="products.jsp?category=all">Click here to go back to Products</a>
	<%
	e.printStackTrace();
	
}
catch (NumberFormatException nfe) {
	%>
	Failure to insert new product<p/>
	<a href="products.jsp?category=all">Click here to go back to Products</a>
	<%
	nfe.printStackTrace();
}
finally {
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