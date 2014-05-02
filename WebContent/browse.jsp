<%@include file="header.jsp" %>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.postgresql.*" %>

<html>
<head>
<style>
productPos
{
	position:absolute;
	left:150px;
	top:55px;
}

buylink
{
	position:absolute;
	top:0px;
	right:0px;
}

input[type="submit"]{
border:0;
color:blue;
text-decoration:underline;

}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Product Browsing</title>
</head>
<body>
<% String name = (String)session.getAttribute("sessionName"); %>
<%if(name == null){
%>Please <a href="login.jsp">log in</a> first<%	
}else{ %>
<% 
	String searchItem = request.getParameter("search");
	String categoryFilter = request.getParameter("category");
	String searchBoxString;
	if(searchItem != null)
	{
		searchBoxString = searchItem;
	}
	else
	{ 
		searchBoxString = "search";
	}
%>
Hello <%= name %>
<buylink><a href="/ShoppingApplication/buyCart.jsp">Buy Shopping Cart</a></buylink>
<form action="browse.jsp" method="GET">
	<%if(categoryFilter != null && !categoryFilter.equals("All producst")){ %>
	<input type="hidden" name="category" value=<%=categoryFilter%>>
	<%} %>
	<input type="text" name="search" value= <%=searchBoxString%>>
<button type="submit">go</button>
</form>
Categories:<br>
<%-- below is the section that displays a list of categories --%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
    ResultSet rs = null;
    //arrayList for storing list of categores for display
    ArrayList<String> categories = new ArrayList<String>();
    
    try {
        // Registering Postgresql JDBC driver with the DriverManager
        Class.forName("org.postgresql.Driver");

        // Open a connection to the database using DriverManager
        conn = DriverManager.getConnection(
            "jdbc:postgresql://localhost/cse135?" +
            "user=postgres&password=postgres");
        
        //begin transaction
        conn.setAutoCommit(false);
        //retrieve categories
        pstmt = conn.prepareStatement("SELECT name FROM categories;");
        //end transaction
        rs = pstmt.executeQuery();
        conn.setAutoCommit(true);
        
        while(rs.next())//put categories into arraylist for display
        {
        	categories.add(rs.getString("name"));
        }
    
    
    //display categories
    %><form action='browse.jsp' action='GET'>
    <%if(searchItem != null){ %>
    	<input type="hidden" name="search" value= <%=searchBoxString%>>
    <%} %>
    	<input type="submit" name="category" value='All products'>
    <%
    for(int i = 0; i < categories.size(); i++)
    {
    	%>
    		<br><input type="submit" name="category" value=<%=categories.get(i)%>>
		</form><%
    }
    
%>

<%--code to add items to cart when returning to browsing --%>
<%
String placeOrder = request.getParameter("addItem");
String quantity = request.getParameter("quantity");
//get the users's primary key ID
conn.setAutoCommit(false);
pstmt = conn.prepareStatement("SELECT id FROM users WHERE users.name=?");
pstmt.setString(1, name);
rs = pstmt.executeQuery();
rs.next();
int uid = rs.getInt("id");
conn.setAutoCommit(true);

if(placeOrder != null)
{
	//begin transaction
	conn.setAutoCommit(false);
	pstmt = conn.prepareStatement("SELECT id FROM products WHERE products.name=?");
	pstmt.setString(1, placeOrder);
	rs = pstmt.executeQuery();
	rs.next();
	int pid = rs.getInt("id");
	pstmt = conn.prepareStatement("INSERT INTO inCart (id, product, quantity) VALUES (?,?,?)");
	pstmt.setInt(1, uid);
	pstmt.setInt(2, pid);
	pstmt.setInt(3, Integer.parseInt(quantity));
	//end transaction
	pstmt.executeUpdate();
	conn.commit();
	conn.setAutoCommit(true);
}

%>
<%-- below is the part that displays products --%>
<productPos>
Products: <br>
<%
		int catf = 0;
		if(categoryFilter != null && !categoryFilter.equals("All products"))
		{
			conn.setAutoCommit(false);
			//retrieve categories
			pstmt = conn.prepareStatement("SELECT id FROM categories WHERE name=?;");
			pstmt.setString(1, categoryFilter);
			//end transaction
			rs = pstmt.executeQuery();
			conn.setAutoCommit(true);
			rs.next();
			catf = rs.getInt("id");
		}
		ArrayList<Integer> catid = new ArrayList<Integer>();
		while(rs.next())
		{
			catid.add(rs.getInt("id"));
		}
	
		//begin transaction
		conn.setAutoCommit(false);
		if(categoryFilter != null && searchItem != null && !categoryFilter.equals("All products"))
		{
			pstmt = conn.prepareStatement(
				"SELECT name, sku, price, category FROM products WHERE products.category=? AND products.name LIKE ?");
			pstmt.setInt(1, catf);
			pstmt.setString(2, "%"+searchItem+"%");
		} else if (searchItem != null){
			pstmt = conn.prepareStatement(
				"SELECT name, sku, price, category FROM products WHERE products.name LIKE ?");
			pstmt.setString(1, "%"+searchItem+"%");
		} else if (categoryFilter != null && !categoryFilter.equals("All products")){
			pstmt = conn.prepareStatement(
				"SELECT name, sku, price, category FROM products WHERE products.category=?");
			pstmt.setInt(1, catf);
		} else {
			pstmt = conn.prepareStatement("SELECT name, sku, price, category FROM products;");
		}
		//end transaction
		rs = pstmt.executeQuery();
		conn.setAutoCommit(true);
		
		//form currently used to be able to select items for order
		%> <form action=order.jsp method=POST> <%
		ResultSet catRef = null;//used to get names of categories
		//display items
		conn.setAutoCommit(false); //setup transactions for getting categories
		while(rs.next())
		{
			pstmt = conn.prepareStatement("SELECT name FROM categories WHERE categories.ID=?");
			pstmt.setInt(1, rs.getInt("category"));
			catRef = pstmt.executeQuery();
			catRef.next();
			%> <input name="placeOrder" type="submit" value="<%=rs.getString("name")%>"> 
				sku:<%=rs.getString("sku") %> price:$<%=rs.getString("price") %> category:<%=catRef.getString("name") %><br> <%
		}
		conn.setAutoCommit(true);//transactions completed after loop
		%> </form>
		</productPos>
		<%
		// Close the ResultSet
        rs.close();

        // Close the Statement
        pstmt.close();

        // Close the Connection
        conn.close();
	} catch (SQLException e){} finally{}}
%>
</body>
</html>