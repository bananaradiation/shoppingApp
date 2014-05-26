import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

/**
 * # of users 		
 * # of categories 	
 * # of products	
 * # of sales		
 * products'categories, randomly
 * users'ages, randomly, [12,100]
 * users'states, randomly,e,g, California, New York
 * products'prices, randomly [1,100], Integer
 * quantities, randomly [1,10], integer
 * 
 **/
public class DataGeneratorBulk 
{
	HashMap<Integer, Integer> hm=new HashMap<Integer, Integer>();
	// CHANGE BUFFER SIZE
	int MAXBuffer=100000;
	public static void main(String[] args) throws Exception
{	

		int Num_users		=	100000*5;
		int Num_categories	=	20*5;
		int Num_products	=	10000*5;
		int Num_sales		=	10000*5;
		long start=System.currentTimeMillis();
		DataGeneratorBulk dg=new DataGeneratorBulk();
		dg.createData( Num_users,Num_categories,Num_products,Num_sales);
		long end=System.currentTimeMillis();
		System.out.println("Finish, running time:"+(end-start)+"ms");
	}
	public void createData(int Num_users,int Num_categories, int Num_products,int Num_sales ) throws Exception
	{

		 Database db=new Database();
	     db.openConn();
	     db.openStatement();
	     db.init();//create tables

	     // CHANGE PATHS FOR WRITE FILES
	     String  usersPath		=	"/home/hannahchen/workspace/shoppingApp/users.txt",
	    		 categoriesPath	=	"/home/hannahchen/workspace/shoppingApp/categories.txt",
	    		 productsPath	=	"/home/hannahchen/workspace/shoppingApp/products.txt",
	     		 salesPath		=	"/home/hannahchen/workspace/shoppingApp/sales.txt";
	     generateUsers(usersPath,Num_users);
	     generateCategories(categoriesPath,Num_categories);
	     generateProducts(productsPath,Num_categories,Num_products);
	     generateSales(salesPath,Num_users,Num_products, Num_sales );
	     db.copy(usersPath,categoriesPath,productsPath,salesPath);
		 db.closeConn();
	}
	
	//INSERT INTO users table
	public void generateUsers(String usersPath,int Num_users)
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		
		int age=0;
		String name="",state="";
		String SQL="";
		String[] states={"Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia",
				"Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts",
				"Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey",
				"New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
				"South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"};
		String[] nameList={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
		Random r=new Random();
		int flag=0;
		// SQLs.add("CSE,owner,35,California");
		while(flag<Num_users)
		{
			age=r.nextInt(88)+12;
			state=states[r.nextInt(states.length)];
			name=nameList[r.nextInt(nameList.length)];
			flag++;
			SQL=name+"_user_"+flag+",customer,"+age+","+state;
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{	writeToFile(usersPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(usersPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating users data");
	}
	//INSERT INTO categories table
	public void generateCategories(String categoriesPath,int Num_categories )
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		String SQL="";
		int flag=0;
		while(flag<Num_categories)
		{
			flag++;
			SQL="C"+flag+",This is the number "+flag+" category";
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{
				writeToFile(categoriesPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(categoriesPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating categories data");
	}
	//INSERT INTO products table
	public void generateProducts(String productsPath,int Num_categories,int Num_products )
	{
		String[] nameList={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
		ArrayList<String> SQLs=new ArrayList<String>();
		String name="",SQL="";
		int flag=0;
		Random r=new Random();
		int cid=0;
		int price=0;
		while(flag<Num_products)
		{
			flag++;
			cid=r.nextInt(Num_categories)+1;
			name=nameList[r.nextInt(nameList.length)];
			price=r.nextInt(100)+1;
			SQL=cid+","+name+"_P"+flag+",SKU_"+flag+","+price;
			hm.put(flag, price);
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{
				writeToFile(productsPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(productsPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating products data");
	}
	//INSERT INTO sales table
	public void generateSales(String salesPath,int Num_users, int Num_products,int Num_sales )
	{
		ArrayList<String> SQLs=new ArrayList<String>();
		String SQL="";
		int flag=0,price=0;
		Random r=new Random();
		int uid=0,pid=0,quantity=0;
		
		while(flag<Num_sales)
		{
			flag++;
			uid=r.nextInt(Num_users)+1;
			pid=r.nextInt(Num_products)+1;
			price=(Integer)hm.get(pid);
			quantity=r.nextInt(10)+1;
			
			SQL=uid+","+pid+","+quantity+","+price;
			SQLs.add(SQL);
			if(SQLs.size()>MAXBuffer)
			{
				writeToFile(salesPath, SQLs);
				SQLs.clear();
			}
		}
		writeToFile(salesPath, SQLs);
		SQLs.clear();
		System.out.println("Successfully generating sales data");
	}
	
	public void  writeToFile(String path, ArrayList<String> al)
	{
		BufferedWriter out = null;    
		try 
		{                                                                        
        	out = new BufferedWriter(new OutputStreamWriter( 
        		new FileOutputStream(path, true)));                              
            
      	   		for(int i=0;i<al.size();i++)
      	   		{
          	   		out.write(al.get(i));
          	   		out.newLine();
      	   		}
      	   		out.close();
      	 }
		catch (Exception e) 
        {                                                     
            e.printStackTrace();                                                    
        }
	}
	
}
