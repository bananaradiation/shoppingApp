<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" import="database.*"   import="java.util.*" errorPage="" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
<script type="text/javascript" src="js/js.js" language="javascript"></script>
</head>

<body>
<%@include file="welcome.jsp" %>

<%

int userID  = (Integer)session.getAttribute("userID");

class Item 
{
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
ArrayList<Item> prod_list=new ArrayList<Item>();
ArrayList<Item> state_list=new ArrayList<Item>();
Item item=null;
Connection conn=null;
Statement stmt,stmt_2,stmt_3;
ResultSet rs=null,rs_2=null,rs_3=null,rsCategory=null;
String SQL=null;

String stateList[] = {"Alabama","Alaska","Arizona","Arkansas",
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

String option=null, state=null, category=null, age=null;
try
{

	try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
	String url="jdbc:postgresql://localhost/cse135";
	String user="postgres";
	String password="postgres";
	conn = DriverManager.getConnection(url, user, password);
	stmt = conn.createStatement();
	stmt_2 =conn.createStatement();
    stmt_3 =conn.createStatement();
    
    try { option = request.getParameter("option");} catch(Exception e){option = null;}
    try { state = request.getParameter("state");} catch(Exception e){state = null;}
    try { category = request.getParameter("category");} catch(Exception e){category = null;}
    try { age = request.getParameter("age");} catch(Exception e){age = null;}   

//     rs=stmt.executeQuery(SQL_1);
    int p_id=0;
    String p_name=null;
    float p_amount_price=0;
//     while(rs.next())
//     {
//         p_id=rs.getInt(1);
//         p_name=rs.getString(2);
//         p_amount_price=rs.getFloat(3);
//         item=new Item();
//         item.setId(p_id);
//         item.setName(p_name);
//         item.setAmount_price(p_amount_price);
//         prod_list.add(item);
    
//     }
//     rs_2=stmt_2.executeQuery(SQL_2);//state not id, many users in one state
//     String s_name=null;
//     float s_amount_price=0;
//     while(rs_2.next())
//     {
//         s_name=rs_2.getString(1);
//         s_amount_price=rs_2.getFloat(2);
//         item=new Item();
//         item.setName(s_name);
//         item.setAmount_price(s_amount_price);
//         state_list.add(item);
//     }
    
    


%>
<p/>

<form action="analytics.jsp" method="POST">
	Sort rows by: 
	<select name="option">
	    <option value="customers">Customers</option>
	    <option value="states">States</option>
	</select><p/>
	Filter sales by:
	<select name="state">
	    <option value="all">All States</option>
	<% for (int i = 0; i < 50; i++) { %>
	    <option value="<%=stateList[i]%>"><%=stateList[i]%></option>
	<% } %>
	</select>
	<%
	
	rsCategory=stmt.executeQuery("SELECT name FROM categories");
    ArrayList<String> categoryDrop = new ArrayList<String>();
    while (rsCategory.next()) {
        categoryDrop.add(rsCategory.getString("name"));
    } 
    %>
	<select name="category">
	    <option value="all">All Categories</option>
        <% for (int i = 0; i < categoryDrop.size(); i++) { %>
        <option value="<%= categoryDrop.get(i)%>"><%= categoryDrop.get(i)%></option>
        <% } %>    
	</select>
	<select name="age">
	    <option value="all">All Ages</option>
	    <option value="12-18">12-18</option>
	    <option value="19-45">19-45</option>
	    <option value="46-65">46-65</option>
	    <option value="65+">65+</option>
	</select>
	<button type="submit">Run Query</button>
</form>


<table align="center" width="98%" border="1">
    <tr align="center">
    <%
    if(("customers").equals(option) | option == (null)) {
    	
    String SQL_cust = "select u.name, sum(c.quantity*p.price) as amount"+
    	    "from users u, sales s, products p "+
    		"where c.uid=u.id and c.pid=p.id "+
    	    "group by u.name "+
    		"order by u.name asc "+
    	    "limit 20;";
    	
    String filter_state=null, filter_category=null, filter_age=null;
    

        	    
    %>
    	<td><strong><font color="#FF0000">CUSTOMER</font></strong></td>
    <%    
    }
    else if(("states").equals(option)) { %>
        <td><strong><font color="#FF0000">STATE</font></strong></td>
    <%        
    }
    %>    
            
            </tr>
            <%=option %>
            <%=state %>
            <%=category %>
            <%=age %>
           
            </table>
<%
}
catch(Exception e)
{
    out.println("<font color='#ff0000'>Error.<br><a href=\"login.jsp\" target=\"_self\"><i>Go Back to Home Page.</i></a></font><br>");

}
finally
{
    conn.close();
}
%>
</body>
</html>