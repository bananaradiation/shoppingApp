<%@ include file="/header.jsp" %>

<title>Products Page</title>
</head>

<body>

	<%
	String name = (String)session.getAttribute("name");
	%>
	Welcome <%= name %>

	
	<%-- -------- Open Connection Code -------- --%>
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
            
                // Get owner categories
                String selectSQL = "SELECT categories.name FROM ((categories JOIN products ON categories.ID=products.category) JOIN users on products.owner=users.ID) WHERE users.name=?";
                pstmt = conn.prepareStatement(selectSQL);
                pstmt.setString(1, name);
                rs = pstmt.executeQuery(selectSQL);
                
                ArrayList<String> categoryList = new ArrayList<String>();
            	while (rs.next()) {
                	categoryList.add(rs.getString("name"));	
                }
            %>
            
            <%-- -------- INSERT Code -------- --%>
            <%
                String action = request.getParameter("action");
                // Check if an insertion is requested
                if (action != null && action.equals("insert")) {

                    // Begin transaction
                    conn.setAutoCommit(false);
					pstmt = conn.prepareStatement("INSERT INTO products (name, sku, price, category, owner) VALUES (?, ?, ?, ?, ?)");

                    pstmt.setString(1, request.getParameter("name"));
                    pstmt.setString(2, request.getParameter("sku"));
                    pstmt.setInt(3, Integer.parseInt(request.getParameter("price")));
                    pstmt.setString(4, request.getParameter("category"));
                    pstmt.setString(5, request.getParameter("owner"));
                    int rowCount = pstmt.executeUpdate();                  
                    
                    // Commit transaction
                    conn.commit();
                    conn.setAutoCommit(true);
					} %>
                    
                    // set action to success
                    <form action="confirmation.jsp" method="GET">
                         <input type="hidden" name="action" value="success"/>
                         <input type="hidden" name="name" value="name"/>
                         <input type="hidden" name="sku" value="sku"/>
                         <input type="hidden" name="price" value="price"/>
                         <input type="hidden" name="category" value="category"/>
                    </form>


            
<!--             HTML STUFFS                 -->

			<table>
	            <tr>
	                <th>Name</th>
	                <th>SKU</th>
	                <th>Category</th>
	                <th>Price</th>
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
			</table>

            <select name="categoryList">
				<% for (int i = 0; i < categoryList.size(); i++) { %>
					<option value="<%= categoryList.get(i) %>"><%= categoryList.get(i) %></option>
				<% } %>
			</select><p/>    
                
                
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