using System;
using System.Linq;
using System.Text;
using System.Web.UI;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using WebApplication1.Models;

namespace WebApplication1
{
    public partial class SetupRoles : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRoles();
            }
        }

        protected void btnSetupRoles_Click(object sender, EventArgs e)
        {
            try
            {
                var roleManager = new RoleManager<IdentityRole>(new RoleStore<IdentityRole>(new ApplicationDbContext()));
                StringBuilder result = new StringBuilder();

                // Create Customer role
                if (!roleManager.RoleExists("Customer"))
                {
                    var roleResult = roleManager.Create(new IdentityRole("Customer"));
                    if (roleResult.Succeeded)
                    {
                        result.AppendLine("? Customer role created successfully.<br/>");
                    }
                    else
                    {
                        result.AppendLine("? Failed to create Customer role.<br/>");
                    }
                }
                else
                {
                    result.AppendLine("? Customer role already exists.<br/>");
                }

                // Create Seller role
                if (!roleManager.RoleExists("Seller"))
                {
                    var roleResult = roleManager.Create(new IdentityRole("Seller"));
                    if (roleResult.Succeeded)
                    {
                        result.AppendLine("? Seller role created successfully.<br/>");
                    }
                    else
                    {
                        result.AppendLine("? Failed to create Seller role.<br/>");
                    }
                }
                else
                {
                    result.AppendLine("? Seller role already exists.<br/>");
                }

                // Create Admin role
                if (!roleManager.RoleExists("Admin"))
                {
                    var roleResult = roleManager.Create(new IdentityRole("Admin"));
                    if (roleResult.Succeeded)
                    {
                        result.AppendLine("? Admin role created successfully.<br/>");
                    }
                    else
                    {
                        result.AppendLine("? Failed to create Admin role.<br/>");
                    }
                }
                else
                {
                    result.AppendLine("? Admin role already exists.<br/>");
                }

                result.AppendLine("<br/><strong>Role setup completed!</strong>");
                result.AppendLine("<br/>You can now register users with Customer, Seller, or Admin roles.");

                ShowResult(result.ToString(), "alert alert-success result-box");
                LoadRoles(); // Refresh the roles list
            }
            catch (Exception ex)
            {
                string errorMsg = $"<strong>Error:</strong> {ex.Message}<br/><br/>";
                errorMsg += "<small>Please make sure:<br/>";
                errorMsg += "1. The database connection is working<br/>";
                errorMsg += "2. ASP.NET Identity tables exist in the database<br/>";
                errorMsg += "3. You have proper permissions</small>";
                
                ShowResult(errorMsg, "alert alert-danger result-box");
                System.Diagnostics.Trace.TraceError($"Role setup error: {ex}");
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadRoles();
        }

        private void LoadRoles()
        {
            try
            {
                var roleManager = new RoleManager<IdentityRole>(new RoleStore<IdentityRole>(new ApplicationDbContext()));
                var roles = roleManager.Roles.Select(r => new { RoleName = r.Name, RoleId = r.Id }).ToList();

                gvRoles.DataSource = roles;
                gvRoles.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError($"Error loading roles: {ex}");
            }
        }

        private void ShowResult(string message, string cssClass)
        {
            lblResult.Text = message;
            pnlResult.CssClass = cssClass;
            pnlResult.Visible = true;
        }
    }
}
