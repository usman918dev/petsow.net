using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.AspNet.Identity.EntityFramework;
using Owin;
using WebApplication1.Models;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace WebApplication1.Account
{
    public partial class Register : Page
    {
        // Add missing control declarations
        protected global::System.Web.UI.WebControls.TextBox Username;
        
        protected void CreateUser_Click(object sender, EventArgs e)
        {
            var manager = Context.GetOwinContext().GetUserManager<ApplicationUserManager>();
            var signInManager = Context.GetOwinContext().GetUserManager<ApplicationSignInManager>();
            var roleManager = new RoleManager<IdentityRole>(new RoleStore<IdentityRole>(new ApplicationDbContext()));

            // Ensure roles exist
            EnsureRolesExist(roleManager);

            // Check if username already exists
            if (IsUsernameExists(Username.Text.Trim()))
            {
                ErrorMessage.Text = "<div class='alert alert-danger'>Username already exists. Please choose a different username.</div>";
                return;
            }

            // Create user with custom username - using email as the UserName for Identity
            var user = new ApplicationUser() 
            { 
                UserName = Email.Text, 
                Email = Email.Text,
                DisplayName = Username.Text.Trim()
            };
            
            IdentityResult result = manager.Create(user, Password.Text);

            if (result.Succeeded)
            {
                // Assign the selected role
                string selectedRole = ddlRole.SelectedValue;
                manager.AddToRole(user.Id, selectedRole);

                signInManager.SignIn(user, isPersistent: false, rememberBrowser: false);
                
                // Redirect based on role
                if (selectedRole == "Seller")
                {
                    Response.Redirect("~/SellerDashboard.aspx");
                }
                else if (selectedRole == "Customer")
                {
                    Response.Redirect("~/Default.aspx");
                }
                else
                {
                    Response.Redirect("~/Default.aspx");
                }
            }
            else
            {
                ErrorMessage.Text = "<div class='alert alert-danger'>" + result.Errors.FirstOrDefault() + "</div>";
            }
        }

        private bool IsUsernameExists(string username)
        {
            using (var context = new ApplicationDbContext())
            {
                return context.Users.Any(u => u.DisplayName == username);
            }
        }

        private void EnsureRolesExist(RoleManager<IdentityRole> roleManager)
        {
            // Create Customer role if it doesn't exist
            if (!roleManager.RoleExists("Customer"))
            {
                roleManager.Create(new IdentityRole("Customer"));
            }

            // Create Seller role if it doesn't exist
            if (!roleManager.RoleExists("Seller"))
            {
                roleManager.Create(new IdentityRole("Seller"));
            }

            // Create Admin role if it doesn't exist (for future use)
            if (!roleManager.RoleExists("Admin"))
            {
                roleManager.Create(new IdentityRole("Admin"));
            }
        }
    }
}