<%@ page contentType="text/html; charset=utf-8" language="java"
	import="java.sql.*" import="database.*" import="java.util.*"
	errorPage=""%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>
<body> <%

// Parameter passing
String option = (String)request.getParameter("option");
String state = (String)request.getParameter("state");
String category = (String)request.getParameter("category");
String age = (String)request.getParameter("age");
String rowPg = (String)request.getParameter("rowPage");
String colPg = (String)request.getParameter("colPage");
if (option == null) {
    option = "customers";
}
if (state == null) {
    state = "all";
}
if (category == null) {
    category = "all";
}
if (age == null) {
    age = "all";
}
if (rowPg == null) {
    rowPg = "1";
}
if (colPg == null) {
    colPg = "1";
}

String stateList[] = {"all","Alabama","Alaska","Arizona","Arkansas",
           "California","Colorado","Connecticut","Delaware","Florida","Georgia",
           "Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky",
           "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota",
           "Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
           "New Jersey","New Mexico","New York","North Carolina","North Dakota",
           "Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
           "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont",
           "Virginia","Washington","West Virginia","Wisconsin","Wyoming"};
ArrayList<String> states = new ArrayList<String>();
for (int i = 0; i < 50; i++) {
    states.add(stateList[i]);
}

class Item {
    private int id=0;
    private String name=null;
    private float amount_price=0f;
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public float getAmount_price() {
        return amount_price;
    }
    public void setAmount_price(float amount_price) {
        this.amount_price = amount_price;
    }
}
ArrayList<Item> p_list=new ArrayList<Item>();
ArrayList<Item> s_list=new ArrayList<Item>();
Item item=null;
Connection conn=null;
Statement stmt,stmt_2,stmt_3;
ResultSet rs=null,rs_2=null,rs_3=null;
String SQL=null;
try
{
    try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
    String url="jdbc:postgresql://localhost/cse135";
    String user="postgres";
    String password="postgres";
    conn =DriverManager.getConnection(url, user, password);
    stmt =conn.createStatement();
    stmt_2 =conn.createStatement();
    stmt_3 =conn.createStatement();
    
    String SQL_prod_all="select p.id, p.name, sum(s.quantity*p.price) as amount from products p, sales s "+
         "where s.pid=p.id "+
         "group by p.name,p.id "+
         "order by p.name asc "+
         "limit 10 "+"offset "+(Integer.parseInt(colPg)-1)*20+";";
    String SQL_prod_cat="select p.id, p.name, sum(s.quantity*p.price) as amount from products p, sales s, categories c "+
         "where s.pid=p.id and c.id=p.cid and c.name='"+category+"'"+
         " group by p.name,p.id "+
         "order by p.name asc "+
         "limit 10 "+"offset "+(Integer.parseInt(colPg)-1)*20+";";
             
//  customer option
    String SQL_cust="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id "+ 
            "group by u.name "+ 
            "order by u.name asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
    String SQL_cust_age_state="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id and u.state='"+state+"' and u.age between "+age+ 
            " group by u.name "+ 
            "order by u.name asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
    String SQL_cust_age="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id and u.age between "+age+ 
            " group by u.name "+ 
            "order by u.name asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
    String SQL_cust_state="select u.name, sum(s.quantity*p.price) as amount from users u, sales s, products p "+
            "where s.uid=u.id and s.pid=p.id and u.state='"+state+"'"+ 
            " group by u.name "+ 
            "order by u.name asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
     
    //  state option
    String SQL_state="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p "+
            "where s.uid=u.id and s.pid=p.id "+ 
            "group by u.state "+ 
            "order by u.state asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";    
    String SQL_state_state="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p "+
            "where s.uid=u.id and s.pid=p.id and u.state='"+state+"'"+ 
            " group by u.state "+ 
            "order by u.state asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
    String SQL_state_age="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p "+
            "where s.uid=u.id and s.pid=p.id and u.age between "+age+ 
            " group by u.state "+ 
            "order by u.state asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
    String SQL_state_age_state="select u.state, sum(s.quantity*p.price) as amount from users u, sales s,  products p "+
            "where s.uid=u.id and s.pid=p.id and u.age between "+age+" and u.state='"+state+"'"+ 
            " group by u.state "+ 
            "order by u.state asc "+
            "limit 20 "+"offset "+(Integer.parseInt(rowPg)-1)*20+";";
            
//     product category filter
    if (category.equals("all")) {
    	rs = stmt.executeQuery(SQL_prod_all);
    }
    else {
    	rs = stmt.executeQuery(SQL_prod_cat);
    }   
    
    int p_id=0;
    String p_name=null;
    float p_amount_price=0;
    while(rs.next()) {
        p_id=rs.getInt(1);
        p_name=rs.getString(2);
        p_amount_price=rs.getFloat(3);
        item=new Item();
        item.setId(p_id);
        item.setName(p_name);
        item.setAmount_price(p_amount_price);
        p_list.add(item);
    }
    
//  row options
    if(option.equals("customers") || option.equals("")) {
    	if (!age.equals("all") && !state.equals("all")) {
    		long startTime = System.currentTimeMillis();
            rs_2=stmt_2.executeQuery(SQL_cust_age_state);
    		long finishTime = System.currentTimeMillis();
    		System.out.println("Time for query: " + (finishTime-startTime) + "ms lin 188");
    	}
    	else if (!age.equals("all")) {
    		long startTime = System.currentTimeMillis();
    		rs_2=stmt_2.executeQuery(SQL_cust_age);
    		long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms lin 194");
    	}
    	else if (!state.equals("all")) {
    		long startTime = System.currentTimeMillis();            
    		rs_2=stmt_2.executeQuery(SQL_cust_state);
    		long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms line 200");
    	}
    	else {
    		long startTime = System.currentTimeMillis();   		
            rs_2=stmt_2.executeQuery(SQL_cust);
            long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms line 206");
    	}
    }
    else if(option.equals("states")) {
    	if (!age.equals("all") && !state.equals("all")) {
            long startTime = System.currentTimeMillis();    		
            rs_2=stmt_2.executeQuery(SQL_state_age_state);
            long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms line 214");
        }
        else if (!age.equals("all")) {
            long startTime = System.currentTimeMillis();
            rs_2=stmt_2.executeQuery(SQL_state_age);
            long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms line 220");
        }
        else if (!state.equals("all")) {
            long startTime = System.currentTimeMillis();
            rs_2=stmt_2.executeQuery(SQL_state_state);
            long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms line 226");
        }
        else {
            long startTime = System.currentTimeMillis();
            rs_2=stmt_2.executeQuery(SQL_state);
            long finishTime = System.currentTimeMillis();
            System.out.println("Time for query: " + (finishTime-startTime) + "ms line 232");
        }
    }
    String s_name=null;
    float s_amount_price=0;
    while(rs_2.next()) {
	    s_name=rs_2.getString(1);
	    s_amount_price=rs_2.getFloat(2);
	    item=new Item();
	    item.setName(s_name);
	    item.setAmount_price(s_amount_price);
	    s_list.add(item);
    }
    
    int i=0,j=0;
    String SQL_3="";  
    float amount=0; 
boolean showDashboard = true;
if (Integer.parseInt(rowPg) != 1) {
	showDashboard = false;	
}
else if (Integer.parseInt(colPg) != 1) {
	showDashboard = false;
} 
if (showDashboard) { %>
	<table>
		<form action="analytics.jsp" method="POST">
			<tr>
				<td>Sort rows by:</td>
				<td><select name="option">
						<option value="<%=option %>"><%=option %></option>
						<%
	        if (option.equals("customers")) { %>
						<option value="states">states</option>
						<%
	        } 
	        else { %>
						<option value="customers">customers</option>
						<%	
	        }
	        %>

				</select></td>
			</tr>
		<tr>
			<td>Filter sales by:</td>
		</tr>
		<tr>
			<td>State:</td>
			<td><select name="state">
					<option value="<%=state %>"><%=state %></option>
					<%
	        for (i = 0; i < 50; i++) { 
	            if (!stateList[i].equals(state)) { %>
					<option value="<%=stateList[i]%>"><%=stateList[i]%></option>
					<% } } %>
			</select></td>
		</tr>
		<%
	    
	    Statement stmtCategory = conn.createStatement();
	    ResultSet rsCategory=stmtCategory.executeQuery("SELECT name FROM categories");
	    ArrayList<String> categoryDrop = new ArrayList<String>();
	    categoryDrop.add("all");
	    while (rsCategory.next()) {
	        categoryDrop.add(rsCategory.getString("name")); }  %>

		<tr>
			<td>Category:</td>
			<td><select name="category">
					<option value="<%=category %>"><%=category %></option>
					<% for (j = 0; j < categoryDrop.size(); j++) { 
	           if (!categoryDrop.get(j).equals(category)) { %>
					<option value="<%= categoryDrop.get(j)%>"><%= categoryDrop.get(j)%></option>
					<% } } %>
			</select></td>
		</tr>

		<% ArrayList<String> ageDrop = new ArrayList<String>();
	    ageDrop.add("all");
	    ageDrop.add("12 and 18");
	    ageDrop.add("18 and 45");
	    ageDrop.add("45 and 65"); 
	    ageDrop.add("65 and 1000"); %>
		<tr>
			<td>Age:</td>
			<td><select name="age">
					<option value="<%=age%>"><%=age %></option>
					<% 
	         for (j = 0; j < ageDrop.size(); j++) { 
	           if (!ageDrop.get(j).equals(age)) { %>
					<option value="<%= ageDrop.get(j)%>"><%= ageDrop.get(j)%></option>
					<% } } %>
			</select></td>
		<tr>
			<td><button type="submit">Run Query</button></td>
		</tr>
		</form>
	</table>
	<%
} %>

	<table align="center" width="98%" border="1">
		<tr align="center">
			<%
        if (option.equals("states")) { %>
			<td><strong><font color="#FF0000">STATE</font></strong></td>
			<% }
        else if (option.equals("customers")) { %>
			<td><strong><font color="#FF0000">CUSTOMERS</font></strong></td>
			<% }
    
    for(i=0;i<p_list.size();i++) {
        p_id            =   p_list.get(i).getId();
        p_name          =   p_list.get(i).getName();
        p_amount_price  =   p_list.get(i).getAmount_price();
        out.print("<td> <strong>"+p_name+"<br>("+p_amount_price+")</strong></td>");
    }
%>
		</tr>
		<%  

    long startTime = System.currentTimeMillis();
    for(i=0;i<s_list.size();i++) {
        s_name          =   s_list.get(i).getName();
        s_amount_price  =   s_list.get(i).getAmount_price();
        out.println("<tr  align=\"center\">");
        out.println("<td><strong>"+s_name+" ("+s_amount_price+")</strong></td>"); 

        for(j=0;j<p_list.size();j++) {    	
	        p_id            =   p_list.get(j).getId();
	        p_name          =   p_list.get(j).getName();
	        p_amount_price  =   p_list.get(j).getAmount_price();
        
	        String SQL_state2="select sum(c.quantity*p.price) as amount from users u, products p, sales c "+
	                "where c.uid=u.id and c.pid=p.id and u.state='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";
	        String SQL_cust2="select sum(c.quantity*p.price) as amount from users u, products p, sales c "+
	                   "where c.uid=u.id and c.pid=p.id and u.name='"+s_name+"' and p.id='"+p_id+"' group by u.state, p.name";
	           
            if("customers".equals(option) || "".equals(option)) {
               rs_3=stmt_3.executeQuery(SQL_cust2);
            }
            else if ("states".equals(option)) {
               rs_3 = stmt_3.executeQuery(SQL_state2); 
            }
            if(rs_3.next()) {
                amount=rs_3.getFloat(1);
                out.print("<td><font color='#0000ff'>"+amount+"</font></td>");
            }
            else {
               out.println("<td><font color='#ff0000'>0</font></td>");
            }
        }
        out.println("</tr>");
    }
    long finishTime = System.currentTimeMillis();
    System.out.println("Time for query: " + (finishTime-startTime) + "ms line 359"); %>
		<form action="analytics.jsp" method="GET">
			<tr>
				<td align="center">
					<% 
	     if (s_list.size() >= 20) {
	         if (option.equals("states")) { %>
					<button type="submit" align="center">Next 20 States</button> <% } 
	         else { %>
					<button type="submit">Next 20 Customers</button> <%
	         }
	     } %> <input type="hidden" name="rowPage"
					value="<%=Integer.parseInt(rowPg)+1 %>" /> <input type="hidden"
					name="colPage" value="<%=Integer.parseInt(colPg) %>" /> <input
					type="hidden" name="age" value="<%=age %>" /> <input type="hidden"
					name="state" value="<%=state %>" /> <input type="hidden"
					name="category" value="<%=category %>" /> <input type="hidden"
					name="option" value="<%=option %>" />
				</td>
		</form>
		<form action="analytics.jsp" method="GET">
			<tr>
				<td align="center">
					<% 
	     if (p_list.size() >= 10) { %>
					<button type="submit">Next 10 Products</button>
			</tr>
			<%
	     } %>
			<input type="hidden" name="colPage"
				value="<%=Integer.parseInt(colPg)+1 %>" /> <input type="hidden"
				name="rowPage" value="<%=Integer.parseInt(rowPg) %>" /> <input
				type="hidden" name="age" value="<%=age %>" /> <input type="hidden"
				name="state" value="<%=state %>" /> <input type="hidden"
				name="category" value="<%=category %>" /> <input type="hidden"
				name="option" value="<%=option %>" />
			</td>
		</form>
		<form action="analytics.jsp" method="GET">
            <tr><td align="center">
            <button type="submit">Analytics Home</button></td></tr>
        </form>
	</table>
	<%
}
catch(Exception e) { 
	out.println(e.getMessage()); }
finally {
	System.out.println("End query");
	conn.close(); }   
%>
</body>
</html>