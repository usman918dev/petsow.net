# Reusable Pagination System Documentation

## Overview
This pagination system provides a reusable, responsive pagination control that can be easily integrated into any page with data lists in your ASP.NET Web Forms application.

## Components

### 1. PaginationControl.ascx
A user control that provides:
- Desktop pagination with numbered pages
- Mobile-friendly pagination with previous/next buttons
- Page size selector
- Record count display
- Bootstrap styling

### 2. PaginationHelper.cs
A helper class that provides:
- SQL pagination query building
- Pagination calculations
- Parameter validation
- Data retrieval with OFFSET/FETCH

## How to Use

### Step 1: Register the Control
Add this to the top of your ASPX page:

```aspx
<%@ Register Src="~/Controls/PaginationControl.ascx" TagPrefix="uc" TagName="Pagination" %>
```

### Step 2: Add the Control to Your Page
Place the pagination control where you want it to appear:

```aspx
<uc:Pagination ID="myPagination" runat="server" 
    OnPageChanged="myPagination_PageChanged" 
    OnPageSizeChanged="myPagination_PageSizeChanged" />
```

### Step 3: Implement Event Handlers
Add these methods to your code-behind:

```csharp
protected void myPagination_PageChanged(object sender, PageChangedEventArgs e)
{
    LoadDataWithPagination(e.CurrentPage, e.PageSize);
}

protected void myPagination_PageSizeChanged(object sender, PageSizeChangedEventArgs e)
{
    LoadDataWithPagination(e.CurrentPage, e.PageSize);
}
```

### Step 4: Create Your Data Loading Method
Use the PaginationHelper to load paginated data:

```csharp
private void LoadDataWithPagination(int currentPage, int pageSize)
{
    try
    {
        // Validate pagination parameters
        PaginationHelper.ValidatePaginationParams(ref currentPage, ref pageSize);

        // Define your queries
        string baseQuery = "SELECT Id, Name, Date FROM MyTable WHERE UserId = @UserId";
        string countQuery = "SELECT COUNT(*) FROM MyTable WHERE UserId = @UserId";
        string orderByClause = "ORDER BY Date DESC";

        // Define parameters
        var parameters = new SqlParameter[]
        {
            new SqlParameter("@UserId", userId)
        };

        // Get paginated data
        var result = PaginationHelper.GetPaginatedData(
            connectionString, baseQuery, countQuery, orderByClause, 
            parameters, currentPage, pageSize);

        // Bind to your controls
        myGridView.DataSource = result.Data;
        myGridView.DataBind();

        myRepeater.DataSource = result.Data;
        myRepeater.DataBind();

        // Update pagination control
        myPagination.SetPaginationData(result.TotalRecords, currentPage, pageSize);
    }
    catch (Exception ex)
    {
        // Handle error
        ShowMessage("Error loading data.", "alert-danger");
    }
}
```

### Step 5: Initialize on Page Load
Call your pagination method in Page_Load:

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        LoadDataWithPagination(1, 10); // Start with page 1, 10 records
    }
}
```

## Advanced Usage

### Custom Page Sizes
You can set custom page size options by modifying the dropdown in the control:

```csharp
// In Page_Load or Page_PreRender
myPagination.ddlPageSize.Items.Clear();
myPagination.ddlPageSize.Items.Add(new ListItem("5", "5"));
myPagination.ddlPageSize.Items.Add(new ListItem("20", "20"));
myPagination.ddlPageSize.Items.Add(new ListItem("50", "50"));
```

### Hide Page Size Selector
```csharp
myPagination.ShowPageSizeSelector = false;
```

### Set Maximum Visible Pages
```csharp
myPagination.MaxVisiblePages = 7; // Default is 5
```

## Filtering with Pagination
When implementing filters, reset to page 1:

```csharp
protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
{
    LoadDataWithPagination(1, myPagination.PageSize); // Reset to page 1
}
```

## Integration Examples

### Example 1: Customer Orders (CustomerDashboard)
```csharp
private void LoadOrdersWithPagination(int currentPage, int pageSize)
{
    string customerId = User.Identity.GetUserId();
    
    string baseQuery = @"
        SELECT OrderId, OrderDate, TotalAmount, Status, PaymentMethod
        FROM Orders
        WHERE CustomerId = @CustomerId";
        
    string countQuery = @"
        SELECT COUNT(*)
        FROM Orders
        WHERE CustomerId = @CustomerId";
        
    string orderByClause = "ORDER BY OrderDate DESC";
    
    var parameters = new SqlParameter[] { new SqlParameter("@CustomerId", customerId) };
    
    var result = PaginationHelper.GetPaginatedData(
        connStr, baseQuery, countQuery, orderByClause, 
        parameters, currentPage, pageSize);
    
    gvOrders.DataSource = result.Data;
    gvOrders.DataBind();
    
    rptOrdersMobile.DataSource = result.Data;
    rptOrdersMobile.DataBind();
    
    ordersPagination.SetPaginationData(result.TotalRecords, currentPage, pageSize);
}
```

### Example 2: Seller Products (SellerDashboard)
```csharp
private void LoadProductsWithPagination(int currentPage, int pageSize)
{
    string sellerId = User.Identity.GetUserId();
    
    string baseQuery = @"
        SELECT Id, Name, Description, Price, Status, Stock
        FROM PetSupplies
        WHERE SellerId = @SellerId";
        
    string countQuery = @"
        SELECT COUNT(*)
        FROM PetSupplies
        WHERE SellerId = @SellerId";
        
    // Add filtering
    string statusFilter = ddlStatusFilter.SelectedValue;
    if (!string.IsNullOrEmpty(statusFilter))
    {
        baseQuery += " AND Status = @Status";
        countQuery += " AND Status = @Status";
    }
    
    string orderByClause = "ORDER BY Id DESC";
    
    var parameters = new List<SqlParameter> 
    { 
        new SqlParameter("@SellerId", sellerId) 
    };
    
    if (!string.IsNullOrEmpty(statusFilter))
    {
        parameters.Add(new SqlParameter("@Status", statusFilter));
    }
    
    var result = PaginationHelper.GetPaginatedData(
        connStr, baseQuery, countQuery, orderByClause, 
        parameters.ToArray(), currentPage, pageSize);
    
    gvProducts.DataSource = result.Data;
    gvProducts.DataBind();
    
    productsPagination.SetPaginationData(result.TotalRecords, currentPage, pageSize);
}
```

## Features

### Responsive Design
- Desktop: Shows numbered pagination with Previous/Next
- Mobile: Simplified Previous/Next with page indicator
- Automatically hides when not needed (? 1 page)

### Customizable
- Page size options (5, 10, 25, 50)
- Maximum visible page numbers
- Show/hide page size selector
- Bootstrap styling

### Performance Optimized
- Uses SQL OFFSET/FETCH for efficient pagination
- Only loads required records
- Validates parameters to prevent errors

### User Friendly
- Shows record count information
- Disabled state for unavailable actions
- Smooth navigation between pages

## Best Practices

1. **Always validate parameters** using `PaginationHelper.ValidatePaginationParams()`
2. **Reset to page 1 when filtering** to avoid empty results
3. **Handle exceptions** gracefully with user-friendly messages
4. **Use appropriate page sizes** based on content complexity
5. **Test with different data volumes** to ensure performance

## Troubleshooting

### Common Issues:
1. **Empty results on page change**: Check if CurrentPage exceeds TotalPages
2. **Performance issues**: Ensure proper indexing on ORDER BY columns
3. **Parameter errors**: Verify parameter names match in all queries
4. **ViewState issues**: Ensure pagination control has stable ID

### Debug Tips:
- Check TotalRecords value
- Verify SQL queries with actual parameters
- Log pagination parameters in event handlers
- Test with different page sizes