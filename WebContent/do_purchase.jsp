<%@ page contentType="text/html; charset=utf-8" language="java" import="java.sql.*" import="database.*"   import="java.util.*" errorPage="" %>
<%@include file="welcome.jsp" %>
<%
if(session.getAttribute("name")!=null)
{

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CSE135</title>
</head>

<body>

<div style="width:20%; position:absolute; top:50px; left:0px; height:90%; border-bottom:1px; border-bottom-style:solid;border-left:1px; border-left-style:solid;border-right:1px; border-right-style:solid;border-top:1px; border-top-style:solid;">
	<table width="100%">
		<tr><td><a href="products_browsing.jsp" target="_self">Show Produts</a></td></tr>
		<tr><td><a href="buyShoppingCart.jsp" target="_self">Buy Shopping Cart</a></td></tr>
	</table>	
</div>
<div style="width:79%; position:absolute; top:50px; right:0px; height:90%; border-bottom:1px; border-bottom-style:solid;border-left:1px; border-left-style:solid;border-right:1px; border-right-style:solid;border-top:1px; border-top-style:solid;">
<p><table align="center" width="80%" style="border-bottom-width:2px; border-top-width:2px; border-bottom-style:solid; border-top-style:solid">
	<tr><td align="left"><font size="+3">
	<%
	String uName=(String)session.getAttribute("name");
	int userID  = (Integer)session.getAttribute("userID");
	String role = (String)session.getAttribute("role");
	String card=null;
	
	PreparedStatement pstmt = null;
	PreparedStatement ustmt = null;
	ResultSet rs;
	int add, pid, quantity, price, cid, ret;
	String state;
	
	int card_num=0;
	try {card=request.getParameter("card"); }catch(Exception e){card=null;}
	try
	{
		 card_num    = Integer.parseInt(card);
		 if(card_num>0)
		 {
	
				Connection conn=null;
				Statement stmt=null;
				try
				{
					
					//String SQL_copy="INSERT INTO sales (uid, pid, quantity, price) select c.uid, c.pid, c.quantity, c.price from carts c where c.uid="+userID+";";

					String SQL="delete from carts where uid="+userID+";";
					
					//String SQL_get="select c.uid, c.pid, c.quantity, c.price from carts c where c.uid="+userID+";";
					String SQL_get="select c.uid, c.pid, c.quantity, c.price, p.cid from carts c LEFT OUTER JOIN products p ON c.pid = p.id where c.uid="+userID+";";
					String SQL_insert= "INSERT INTO sales (uid, pid, quantity, price) VALUES ("+userID+", ?, ?, ?)";
					String SQL_updateCV="UPDATE customerView" + " "+
										"SET amt = amt+?" + " "+
										"WHERE uid = "+userID+";";
										
					String SQL_updatePV="UPDATE productView" + " "+
										"SET amt = amt+?" + " "+
										"WHERE uid = "+userID+" AND pid = ?;";
										
					String SQL_updateSV="UPDATE stateView" + " "+
										"SET amt = amt+?" + " "+
										"WHERE state = ?" + " " +
												"AND cid = ?;";
												
					String SQL_insertCV = "INSERT INTO customerView (uid, state, amt) VALUES ("+userID+", ?, ?);";
					String SQL_insertPV = "INSERT INTO productView (uid, pid, cid, amt) VALUES ("+userID+", ?, ?, ?);";
					String SQL_insertSV = "INSERT INTO stateView (cid, state, amt) VALUES (?, ?, ?);";
					
					//String SQL_getcid = "SELECT cid FROM products WHERE id = ?;";
					String SQL_getState = "SELECT state FROM users WHERE users.id = "+userID+";";
					
					pstmt = null;
					ustmt = null;
					
					try{Class.forName("org.postgresql.Driver");}catch(Exception e){System.out.println("Driver error");}
			        String url="jdbc:postgresql://localhost/project3";
			        String user="postgres";
			        String password="postgres";
					conn =DriverManager.getConnection(url, user, password);
					stmt =conn.createStatement();
				
					try{
					
							conn.setAutoCommit(false);
							/**record log,i.e., sales table**/
							//stmt.execute(SQL_copy);
							rs = stmt.executeQuery(SQL_getState);
							rs.next();
							state = rs.getString("state");
							rs = stmt.executeQuery(SQL_get);
							//state = "Kansas";
							while(rs.next())
							{
								//uid = rs.getInt("uid");
								pid = rs.getInt("pid");
								quantity = rs.getInt("quantity");
								price = rs.getInt("price");
								cid = rs.getInt("cid");
								//pstmt = conn.prepareStatement(SQL_getcid);
								//pstmt.setInt(1, pid);
								//ts = pstmt.executeQuery();
								//ts.next();
								//cid = ts.getInt("cid");
								
								pstmt = conn.prepareStatement(SQL_insert);
								//pstmt.setInt(1, uid);
								pstmt.setInt(1, pid);
								pstmt.setInt(2, quantity);
								pstmt.setInt(3, price);
								pstmt.executeUpdate();
								
								add = quantity * price;
								
								ustmt = conn.prepareStatement(SQL_updateCV);
								ustmt.setInt(1, add);
								//ustmt.setInt(2, uid);
								ret = ustmt.executeUpdate();
								if(ret < 1){
									ustmt = conn.prepareStatement(SQL_insertCV);
									ustmt.setString(1, state);
									ustmt.setInt(2, add);
									ustmt.executeUpdate();
								}
								
								ustmt = conn.prepareStatement(SQL_updatePV);
								ustmt.setInt(1, add);
								//ustmt.setInt(2, uid);
								ustmt.setInt(2, pid);
								ret = ustmt.executeUpdate();
								if(ret < 1){
									ustmt = conn.prepareStatement(SQL_insertPV);
									ustmt.setInt(1, pid);
									ustmt.setInt(2, cid);
									ustmt.setInt(3, add);
									ustmt.executeUpdate();
								}
								
								ustmt = conn.prepareStatement(SQL_updateSV);
								ustmt.setInt(1, add);
								ustmt.setString(2, state);
								//ustmt.setInt(2, uid);
								ustmt.setInt(3, cid);
								ret = ustmt.executeUpdate();
								if(ret < 1){
									ustmt = conn.prepareStatement(SQL_insertSV);
									ustmt.setInt(1, cid);
									ustmt.setString(2, state);
									ustmt.setInt(3, add);
									ustmt.executeUpdate();
								}
							}
							
							stmt.execute(SQL);
							conn.commit();
							
							conn.setAutoCommit(false);
							out.println("Dear customer '"+uName+"', Thanks for your purchasing.<br> Your card '"+card+"' has been successfully proved. <br>We will ship the products soon.");
							out.println("<br><font size=\"+2\" color=\"#990033\"> <a href=\"products_browsing.jsp\" target=\"_self\">Continue purchasing</a></font>");
							String sql_top_update="drop table topP; create table topP as ( SELECT prod.name, prod.id, prod.total FROM (SELECT name, products.id, sum(amt) AS total FROM productView, products WHERE productView.pid=products.id GROUP BY products.id, products.name) AS prod ORDER BY total DESC LIMIT 10);";
							Statement stmt_top = conn.createStatement();
							stmt_top.execute(sql_top_update);
							conn.commit();
							
							conn.setAutoCommit(true);
					}
					catch(Exception e)
					{
						out.println("Fail! Please try again <a href=\"purchase.jsp\" target=\"_self\">Purchase page</a>.<br><br>");
						e.printStackTrace();
					}
					conn.close();
				}
				catch(Exception e)
				{
						out.println("<font color='#ff0000'>Error.<br><a href=\"purchase.jsp\" target=\"_self\"><i>Go Back to Purchase Page.</i></a></font><br>");
						
				}
			}
			else
			{
			
				out.println("Fail! Please input valid credit card numnber.  <br> Please <a href=\"purchase.jsp\" target=\"_self\">buy it</a> again.");
			}
		}
	catch(Exception e) 
	{ 
		out.println("Fail! Please input valid credit card numnber.  <br> Please <a href=\"purchase.jsp\" target=\"_self\">buy it</a> again.");
	}
%>
	
	</font><br>
</td></tr>
</table>
</div>
</body>
</html>
<%}%>