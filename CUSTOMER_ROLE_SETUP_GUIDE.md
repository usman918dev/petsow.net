# Customer & Seller Role Setup Guide

## ?? IMPORTANT: Fix for "Role Customer does not exist" Error

### Quick Fix Steps:

**?? FIRST: Stop the debugger if it's running (Shift+F5 in Visual Studio)**

Then follow ONE of these options:

---

## Option 1: Automatic Setup (Recommended) ?

1. **Stop the debugger** if running
2. **Build the solution** (Ctrl+Shift+B)
3. **Run your application** (F5)
4. Navigate to: `http://localhost:YOUR_PORT/SetupRoles.aspx`
5. Click **"Setup Roles"** button
6. Wait for success message
7. Now you can register as Customer or Seller!

---

## Option 2: The roles will auto-create on registration ?

The registration page has been updated to automatically create roles if they don't exist. Just:

1. **Stop the debugger** 
2. **Rebuild the solution** (Ctrl+Shift+B)
3. **Start debugging again** (F5)
4. Try registering - roles will be created automatically!

---

## What Was Changed:

### 1. **Register.aspx** - Updated
- Added "Customer" role option to dropdown
- Added role descriptions
- Default selection prompt

### 2. **Register.aspx.cs** - Updated
- Added automatic role creation before user registration
- Creates Customer, Seller, and Admin roles if they don't exist
- Redirects based on role:
  - **Customer** ? Home page (Default.aspx)
  - **Seller** ? Seller Dashboard
  - **Admin** ? Home page

### 3. **ProductDetails.aspx.cs** - Updated
- Only **Customers** can add items to cart
- Displays appropriate messages for non-customers
- Requires login to purchase

### 4. **Checkout.aspx.cs** - Updated
- Only **Customers** can checkout
- Saves **CustomerId** to Orders table
- Redirects non-customers to home page

### 5. **Cart.aspx.cs** - Updated
- Only **Customers** can access cart
- Requires authentication

### 6. **CustomerDashboard.aspx** - Created NEW
- Shows order history for logged-in customer
- View order details
- Track order status
- Customer-only access

### 7. **SetupRoles.aspx** - Created NEW
- Utility page to create roles
- Shows existing roles
- Easy role management

### 8. **Database Schema** - Updated
- Orders table now includes **CustomerId** (FK to AspNetUsers)
- Links orders to specific customer accounts

---

## Testing the Complete Flow:

### As a Customer:

1. **Register** as Customer role
2. **Browse** products on home page
3. **Click** on a product to view details
4. **Add to Cart** (only customers can do this)
5. **View Cart** - update quantities or remove items
6. **Checkout** - fill in delivery details
7. **Confirm Order** - order saved with your customer ID
8. **View Order Confirmation** on Thank You page
9. **Access Customer Dashboard** at `/CustomerDashboard.aspx` to see your orders

### As a Seller:

1. **Register** as Seller role
2. **Redirected** to Seller Dashboard
3. **Add Products** for sale
4. **Manage Products** - edit, view status
5. **Cannot purchase** - sellers can only sell

---

## Database Tables Required:

### Make sure you've run the database setup:

1. Navigate to: `http://localhost:YOUR_PORT/SetupDatabase.aspx`
2. Click "Setup Database Tables"

**Tables Created:**
- `Orders` - with CustomerId column
- `OrderItems` - order line items

### Verify Tables Exist:

Run this SQL in your database:
```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('Orders', 'OrderItems', 'AspNetRoles', 'AspNetUsers')
```

You should see all 4 tables.

---

## Common Errors & Solutions:

### Error: "Role Customer does not exist"
**Solution:** 
- Stop debugger
- Rebuild solution
- Run `/SetupRoles.aspx` OR just try registering again (auto-creates)

### Error: "Invalid object name 'Orders'"
**Solution:** 
- Run `/SetupDatabase.aspx` to create tables

### Error: "Cannot insert NULL into CustomerId"
**Solution:** 
- Must be logged in as Customer to checkout
- CustomerId is required in Orders table

### Can't add to cart as Seller
**Expected Behavior:** 
- Only Customers can purchase
- Sellers can only list products
- Register a separate Customer account to buy

### Don't see CustomerDashboard in menu
**Solution:** 
- Navigate manually to `/CustomerDashboard.aspx`
- Or add link to Site.Master navigation for customers

---

## Navigation URLs:

- **Home:** `/Default.aspx`
- **Register:** `/Account/Register.aspx`
- **Login:** `/Account/Login.aspx`
- **Customer Dashboard:** `/CustomerDashboard.aspx` (Customers only)
- **Seller Dashboard:** `/SellerDashboard.aspx` (Sellers only)
- **Admin Dashboard:** `/AdminDashboard.aspx` (Admins only)
- **Cart:** `/Cart.aspx` (Customers only)
- **Setup Database:** `/SetupDatabase.aspx`
- **Setup Roles:** `/SetupRoles.aspx`

---

## Role Permissions Summary:

| Feature | Customer | Seller | Admin |
|---------|----------|--------|-------|
| Browse Products | ? | ? | ? |
| View Product Details | ? | ? | ? |
| Add to Cart | ? | ? | ? |
| Checkout | ? | ? | ? |
| View Own Orders | ? | ? | ? |
| Add Products | ? | ? | ? |
| Manage Products | ? | ? | ? |
| Approve Products | ? | ? | ? |
| View All Products | ? | ? | ? |

---

## Step-by-Step: First Time Setup

1. **Stop Debugger** (Shift+F5)
2. **Clean Solution** (Build ? Clean Solution)
3. **Rebuild Solution** (Ctrl+Shift+B)
4. **Start Application** (F5)
5. Go to `/SetupRoles.aspx` - Setup roles
6. Go to `/SetupDatabase.aspx` - Setup tables (if not already done)
7. Go to `/Account/Register.aspx` - Register as Customer
8. Start shopping!

---

## ?? You're All Set!

Your e-commerce application now has:
- ? Customer and Seller roles
- ? Role-based access control
- ? Customer order tracking
- ? Seller product management
- ? Secure checkout with user accounts
- ? Order history per customer

**Need Help?** Check the logs in Visual Studio Output window for detailed error messages.
