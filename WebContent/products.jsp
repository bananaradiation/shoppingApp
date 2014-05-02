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

<title>Products</title>
</head>

<body>

<%
String name = (String)session.getAttribute("sessionName");
String action = request.getParameter("action");
String category = request.getParameter("category");

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String selectSQL;
Statement st = null;

try {
    // Registering Postgresql JDBC driver with the DriverManager
    Class.forName("org.postgresql.Driver");

    // Open a connection to the database using DriverManager
    conn = DriverManager.getConnection(
        "jdbc:postgresql://localhost/cse135?" +
        "user=postgres&password=postgres");
    
	int ownerID = Integer.parseInt((String)session.getAttribute("sessionID"));
				
	if (action != null && action.equals("update")) {
		String productName = request.getParameter("productName");
		String sku = request.getParameter("sku");
		String productCategory = request.getParameter("productCategory");
		java.math.BigDecimal price = new java.math.BigDecimal(request.getParameter("price"));
		int productID = Integer.parseInt(request.getParameter("productID"));

		// Start Transaction
		conn.setAutoCommit(false);
	    
	    pstmt = conn.prepareStatement("UPDATE products SET name = ?, sku = ?, category = ?, price = ? WHERE ID = ?");
	    pstmt.setString(1, productName);
	    pstmt.setString(2, sku);
	    pstmt.setInt(3, productID);
	    pstmt.setBigDecimal(4, price);
	    pstmt.setInt(5, productID);
	    int rowCount = pstmt.executeUpdate();

	    if (rowCount > 0) {
		    conn.commit();
		    conn.setAutoCommit(true);
		    // End Transaction
	    }
	}
	if (action != null && action.equals("delete")) {
		int productID = Integer.parseInt(request.getParameter("productID"));
	    // Start transaction
	    conn.setAutoCommit(false);
	
	    pstmt = conn.prepareStatement("DELETE FROM products WHERE ID = ?");
	    pstmt.setInt(1, productID);
	    int rowCount = pstmt.executeUpdate();
	
	    if (rowCount > 0) {
		        conn.commit();
		        conn.setAutoCommit(true);
				// End transaction
	    }
	}

	// populate sidebar with valid categories
	
	pstmt = conn.prepareStatement("SELECT name FROM categories WHERE owner = ?");
	pstmt.setInt(1, ownerID);
	rs = pstmt.executeQuery();		

	ArrayList<String> categoryDrop = new ArrayList<String>();
	while (rs.next()) {
		categoryDrop.add(rs.getString("name"));
	} %>
	
	Hello <%= name %> <p/>
	
	<div style="width:150px;float:left;display:inline-block;">
		<div class="filter">
			<center>
			<a href="products.jsp?category=all">All Products</a></p>
			<% 
			for (int i = 0; i < categoryDrop.size(); i++) { %>
				<a href="products.jsp?category=<%= categoryDrop.get(i)%>"><%= categoryDrop.get(i)%></a></p>
			<%
			}
			%>
			</center>
		</div>
		<div class="search">
			<form action="products.jsp" method="GET">
				<input type="text" value="" name="query" size="10"/> 
				<input type="hidden" name="action" value="search"/>
				<input type="hidden" name="category" value="<%= category%>"/>
				<center><input type="submit" value="Search Products"/></center>
			</form>
		</div>
	</div>

	<%
	String searchFor = request.getParameter("query");
	String sel = "products.ID AS pID, products.name AS productName, sku, price, categories.name AS catName";
	
	if (action != null && action.equals("search") && category.equals("all")) {
		pstmt = conn.prepareStatement("SELECT "+ sel+ " FROM (categories JOIN products ON categories.ID=products.category WHERE categories.owner = ?) WHERE products.name = ?");	
		pstmt.setInt(1, ownerID);
		pstmt.setString(2, "%"+searchFor+"%");
		rs = pstmt.executeQuery();
	}
	else if (action != null && action.equals("search")) {
		pstmt = conn.prepareStatement("SELECT "+sel+ " FROM categories, products WHERE categories.owner = ? AND products.name = ? AND categories.ID=products.category");
		pstmt.setInt(1, ownerID);
		pstmt.setString(2, "%"+searchFor+"%");
		rs = pstmt.executeQuery();
	}
	else if (category != null && category.equals("all")) {
		pstmt = conn.prepareStatement("SELECT "+sel+" FROM categories JOIN products ON categories.ID=products.category WHERE categories.owner = ?");
		pstmt.setInt(1, ownerID);
		rs = pstmt.executeQuery();
	}
	else if (category != null) {
		pstmt = conn.prepareStatement("SELECT "+sel+" FROM categories JOIN products ON products.category=categories.ID WHERE categories.name = ?");	
		pstmt.setString(1, category);
		rs = pstmt.executeQuery();
	} %>
	<div class="content">
	<table>
		<tr>		
			<th>Name</th>
		    <th>SKU</th>
		    <th>Category</th>
		    <th>Price</th>
		</tr>
		<tr>
			<form action="userConfirmation.jsp" method="POST">
		        <input type="hidden" name="action" value="insert"/>
				<td><input type="text" value="" name="productName" size="10"/></td>
		        <td><input type="text" value="" name="sku" size="10"/></td>
		        <td><select name="productCategory" width="10">
				<% for (int i = 0; i < categoryDrop.size(); i++) { %>
						<option value="<%= categoryDrop.get(i)%>"><%= categoryDrop.get(i)%></option>
				<% } %>
			  		</select></td>
		        <td><input type="text" value="" name="price" size="10"/></td>
		        <td><input type="submit" value="Insert"/></td>
	        </form>
		</tr> <%	
 	while (rs.next()) {	%>
		<tr>
			<form action="products.jsp?category=all" method="POST">
		   		<td><input value="<%=rs.getString("productName")%>" name="productName" size="10"/></td>
		    	<td><input value="<%=rs.getString("sku")%>" name="sku" size="10"/></td>
		    	<td><select name="productCategory" width="10">
		    			<option value="<%=rs.getString("catName")%>"><%=rs.getString("catName")%></option>
						<% 
						for (int i = 0; i < categoryDrop.size(); i++) { 
							if (!categoryDrop.get(i).equals(rs.getString("catName"))) { %>
							<option value="<%= categoryDrop.get(i)%>"><%= categoryDrop.get(i)%></option>
							<%
							} 
						} %>
				  		</select></td>
		    	<td><input value="<%=rs.getInt("price")%>" name="price" size="10"/></td>
		    	<input type="hidden" name="action" value="update"/>
	        	<input type="hidden" name="productID" value="<%= rs.getInt("pID")%>"/>
			    <td><input type="submit" value="Update"></td>
	   		</form>
	   		<form action="products.jsp?category=all" method="POST">
		 	        <input type="hidden" name="action" value="delete"/>
		 	        <input type="hidden" name="productID" value="<%= rs.getInt("pID") %>"/>
			    	<td><input type="submit" value="Delete"/></td>
			</form>
 		</tr> <%
 		} %>
	</table> 
	</div><%
}
catch (SQLException e) { 
	e.printStackTrace();
	%>
	Requested data modification failed. <p/>
	<a href="products.jsp?category=all">Click here to go back to Products</a>
	<%
    
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