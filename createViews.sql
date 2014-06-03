CREATE TABLE customerView (
	cid 	INTEGER PRIMARY KEY, 
	state 	TEXT NOT NULL, 
	amt 	INTEGER
);
INSERT INTO customerView(CID, STATE, AMT)
(SELECT sales.uid as CID, users.state as STATE, SUM(sales.quantity*sales.price) as AMT
FROM sales JOIN users ON sales.uid=users.id
GROUP BY sales.uid, users.state);


CREATE TABLE productView (
	id 		SERIAL PRIMARY KEY,
	pid		INTEGER NOT NULL,
	uid		INTEGER NOT NULL,
	cid		INTEGER NOT NULL,
	amt     INTEGER
);
INSERT INTO productView(PID, UID, CID, AMT)
(SELECT sales.pid AS PID, sales.uid AS UID, products.cid AS CID, SUM(sales.quantity*sales.price) AS AMT
FROM sales, products, categories
WHERE sales.pid=products.id AND products.cid=categories.id
GROUP BY sales.pid, sales.uid, products.cid
);


CREATE TABLE stateView(
	id		SERIAL PRIMARY KEY,
	state   TEXT NOT NULL,
	cid     INTEGER NOT NULL,
	amt 	INTEGER 
);
INSERT INTO stateView(STATE,CID,AMT)
(SELECT users.state AS STATE, products.cid AS CID, SUM(sales.quantity*sales.price) AS AMT
FROM users, sales, products
WHERE users.id=sales.uid AND products.id=sales.pid
GROUP BY products.cid, users.state
);


-- state row, no filter
SELECT state, sum(amt) 
FROM stateView
GROUP BY state
ORDER BY sum(amt) DESC
LIMIT 20;

-- state row, state filter
SELECT state, sum(amt) 
FROM stateView
WHERE state = '+"state"+'
GROUP BY state