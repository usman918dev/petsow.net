# Pet Store Web Application

A comprehensive ASP.NET Web Forms e-commerce application for pet supplies, toys, accessories, and feeds.

## 📋 Overview

This web application provides a complete pet store solution with user role management, product catalog, shopping cart functionality, and administrative features. The application supports three types of users: Customers, Sellers, and Administrators.

## ✨ Features

### Customer Features
- Browse pet products (toys, accessories, feeds)
- Product details and search functionality
- Shopping cart management
- User registration and authentication
- Order placement and checkout process
- Customer dashboard for order management

### Seller Features
- Product management (add, edit, delete products)
- Inventory tracking
- Order fulfillment
- Sales analytics
- Seller-specific dashboard

### Admin Features
- User management (customers, sellers, admins)
- Product approval and moderation
- Order management
- System configuration
- Admin dashboard with comprehensive controls

## 🛠️ Technical Stack

- **Framework**: ASP.NET Web Forms 4.7.2
- **Language**: C#
- **Database**: SQL Server LocalDB
- **ORM**: Entity Framework 6.4.4
- **Authentication**: ASP.NET Identity 2.2.4
- **Frontend**: Bootstrap 5.2.3, jQuery 3.7.0
- **Build Tool**: MSBuild

## 📁 Project Structure

```
WebApplication1/
├── Account/                    # User authentication pages
│   ├── Login.aspx
│   ├── Register.aspx
│   ├── ManagePassword.aspx
│   └── ManageLogins.aspx
├── App_Data/                   # Database files
├── App_Start/                  # Application startup configuration
│   ├── BundleConfig.cs
│   ├── IdentityConfig.cs
│   ├── RouteConfig.cs
│   └── Startup.Auth.cs
├── Content/                    # CSS and styling files
├── Database/                   # Database scripts
├── Helpers/                    # Utility classes
├── Models/                     # Data models
│   ├── CartItem.cs
│   └── IdentityModels.cs
├── Scripts/                    # JavaScript files
├── Uploads/                    # File upload storage
├── AdminDashboard.aspx         # Admin management interface
├── Cart.aspx                   # Shopping cart
├── Checkout.aspx               # Order checkout
├── CustomerDashboard.aspx      # Customer portal
├── Default.aspx                # Homepage
├── ProductDetails.aspx         # Product information
├── SellerDashboard.aspx        # Seller portal
├── SetupDatabase.aspx          # Database initialization
├── SetupRoles.aspx             # Role configuration
├── Site.Master                 # Master page template
└── ThankYou.aspx              # Order confirmation
```

## 🚀 Getting Started

### Prerequisites

- Visual Studio 2017 or later
- .NET Framework 4.7.2
- SQL Server LocalDB
- IIS Express

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd WebApplication1
   ```

2. **Restore NuGet packages**
   ```bash
   nuget restore
   ```

3. **Set up the database**
   - The application uses SQL Server LocalDB
   - Navigate to `SetupDatabase.aspx` to initialize the database
   - Run `SetupRoles.aspx` to configure user roles

4. **Build and run**
   - Open the solution in Visual Studio
   - Build the project (Ctrl+Shift+B)
   - Run with IIS Express (F5)

### Database Management

The application includes several database management tools:

1. **Automatic Setup**: Tables are created automatically on first run via `Global.asax.cs`
2. **Manual Setup**: Use `SetupDatabase.aspx` and `SetupRoles.aspx` for manual initialization
3. **Database Scripts**: Located in `/Database/` folder
   - `CreatePetSuppliesTable.sql` - Creates the products table
   - `Add_DisplayName_Column.sql` - Adds custom DisplayName field
   - `ClearAllData.sql` - Removes all data while preserving structure

**To clear all data from the database:**
```sql
-- Execute the ClearAllData.sql script or run these commands:
-- This will remove all users, products, and orders but keep table structure
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
DELETE FROM [dbo].[OrderItems]
DELETE FROM [dbo].[Orders]
DELETE FROM [dbo].[PetSupplies]
DELETE FROM [dbo].[AspNetUserClaims]
DELETE FROM [dbo].[AspNetUserLogins]
DELETE FROM [dbo].[AspNetUserRoles]
DELETE FROM [dbo].[AspNetUsers]
DELETE FROM [dbo].[AspNetRoles]
EXEC sp_msforeachtable "ALTER TABLE ? CHECK CONSTRAINT all"
```

### Database Configuration

The application uses Entity Framework Code First with LocalDB. The connection string is configured in `Web.config`:

```xml
<connectionStrings>
  <add name="DefaultConnection" 
       connectionString="Data Source=(LocalDb)\MSSQLLocalDB;AttachDbFilename=|DataDirectory|\aspnet-WebApplication1-20250906055757.mdf;Initial Catalog=aspnet-WebApplication1-20250906055757;Integrated Security=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

## 📊 Database Schema

The application uses ASP.NET Identity for user management and custom tables for e-commerce functionality. All tables are created automatically during application startup.

### Identity Tables (ASP.NET Identity)
- **AspNetUsers**: User accounts with authentication data
  - `Id` (Primary Key), `UserName`, `Email`, `PasswordHash`, `SecurityStamp`
  - `EmailConfirmed`, `PhoneNumber`, `PhoneNumberConfirmed`, `TwoFactorEnabled`
  - `LockoutEndDateUtc`, `LockoutEnabled`, `AccessFailedCount`
  - `DisplayName` (Custom field for user display names)

- **AspNetRoles**: User roles (Admin, Seller, Customer)
  - `Id` (Primary Key), `Name`

- **AspNetUserRoles**: User-Role mappings
  - `UserId` (FK to AspNetUsers), `RoleId` (FK to AspNetRoles)

- **AspNetUserClaims**: User claims for authorization
  - `Id`, `UserId` (FK to AspNetUsers), `ClaimType`, `ClaimValue`

- **AspNetUserLogins**: External login providers
  - `LoginProvider`, `ProviderKey`, `UserId` (FK to AspNetUsers)

### E-commerce Tables (Custom)
- **PetSupplies**: Product catalog
  - `Id` (Primary Key, Identity), `Name`, `Description`, `Price`
  - `ImageUrl`, `Category`, `SellerId` (FK to AspNetUsers), `SellerName`
  - `Status` (Pending/Approved/Rejected), `CreatedDate`
  - `Stock`, `StockStatus` (In Stock/Out of Stock)

- **Orders**: Customer order headers
  - `OrderId` (Primary Key, Identity), `CustomerId` (FK to AspNetUsers)
  - `CustomerName`, `Address`, `Phone`, `Email`
  - `PaymentMethod`, `TotalAmount`, `OrderDate`, `Status`

- **OrderItems**: Order line items
  - `OrderItemId` (Primary Key, Identity), `OrderId` (FK to Orders)
  - `ProductId` (FK to PetSupplies), `ProductName`
  - `Quantity`, `Price`

### Database Indexes
- **Performance indexes on frequently queried columns:**
  - `IX_Orders_OrderDate` - Orders by date (DESC)
  - `IX_Orders_CustomerId` - Orders by customer
  - `IX_OrderItems_OrderId` - Order items by order
  - `IX_OrderItems_ProductId` - Order items by product
  - `IX_PetSupplies_SellerId` - Products by seller
  - `IX_PetSupplies_Status` - Products by approval status
  - `IX_AspNetUsers_DisplayName` - Users by display name

### Foreign Key Relationships
- `Orders.CustomerId` → `AspNetUsers.Id`
- `OrderItems.OrderId` → `Orders.OrderId` (CASCADE DELETE)
- `OrderItems.ProductId` → `PetSupplies.Id`
- `PetSupplies.SellerId` → `AspNetUsers.Id`

## 🔐 User Roles

1. **Customer**
   - Browse and purchase products
   - Manage cart and orders
   - View order history

2. **Seller**
   - Add and manage products
   - Process orders
   - View sales reports

3. **Admin**
   - Manage all users and products
   - Approve seller products
   - System administration

## 🎨 UI Components

- **Responsive Design**: Bootstrap 5.2.3 for mobile-friendly interface
- **Master Pages**: Consistent layout across all pages
- **AJAX Support**: Enhanced user experience
- **Font Awesome Icons**: Modern iconography
- **jQuery**: Client-side interactivity

## 📝 Key Pages

| Page | Description |
|------|-------------|
| `Default.aspx` | Homepage with featured products |
| `ProductDetails.aspx` | Individual product information |
| `Cart.aspx` | Shopping cart management |
| `Checkout.aspx` | Order placement |
| `AdminDashboard.aspx` | Admin control panel |
| `CustomerDashboard.aspx` | Customer account management |
| `SellerDashboard.aspx` | Seller product management |

## 🔧 Configuration

### Bundle Configuration
Bundling and minification are configured in `App_Start/BundleConfig.cs` for optimized resource loading.

### Authentication
ASP.NET Identity is configured for user authentication with role-based authorization.

### Routing
Friendly URLs are enabled for better SEO and user experience.

## 🚀 Deployment

1. **Publish Configuration**
   - Use Visual Studio's Publish feature
   - Configure connection strings for production
   - Update `Web.Release.config` for production settings

2. **Database Migration**
   - Update connection strings for production database
   - Run database initialization scripts

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🐛 Known Issues

- Authentication mode is currently set to "None" in Web.config
- Some CSS/JS bundling configurations may need adjustment for production

## 📞 Support

For questions or issues, please create an issue in the repository or contact the development team.

---

**Note**: This is a demonstration project for educational purposes. For production use, ensure proper security configurations and database optimization.