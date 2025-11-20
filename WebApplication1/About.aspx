<%@ Page Title="About Us - Pet Supplies Store" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="WebApplication1.About" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --primary-color: #764ba2;
            --accent-color: #667eea;
        }

        .hero-section {
            background: var(--primary-gradient);
            color: white;
            padding: 100px 0;
            margin-bottom: 80px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .hero-section::before {
            content: '';
            position: absolute;
            bottom: -50px;
            left: 0;
            width: 100%;
            height: 100px;
            background: white;
            transform: skewY(-3deg);
        }

        .hero-section h1 {
            font-size: 3.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }

        .hero-section p {
            font-size: 1.3rem;
            opacity: 0.9;
            max-width: 600px;
            margin: 0 auto;
        }

        .feature-card {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            height: 100%;
            border: none;
        }

        .feature-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 1.5rem;
            display: block;
        }

        .feature-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
            color: #333;
        }

        .feature-text {
            color: #666;
            line-height: 1.6;
        }

        .stats-section {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 80px 0;
            margin: 80px 0;
        }

        .stat-card {
            text-align: center;
            padding: 2rem;
        }

        .stat-number {
            font-size: 3rem;
            font-weight: bold;
            color: var(--primary-color);
            display: block;
        }

        .stat-label {
            color: #666;
            font-size: 1.1rem;
            margin-top: 0.5rem;
        }

        .section-title {
            text-align: center;
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 3rem;
            color: #333;
            position: relative;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -15px;
            left: 50%;
            transform: translateX(-50%);
            width: 60px;
            height: 4px;
            background: var(--primary-gradient);
            border-radius: 2px;
        }

        .team-section {
            padding: 80px 0;
        }

        .mission-section {
            background: var(--primary-gradient);
            color: white;
            padding: 80px 0;
            margin: 80px 0;
            text-align: center;
        }

        .mission-text {
            font-size: 1.3rem;
            line-height: 1.8;
            max-width: 800px;
            margin: 0 auto;
            opacity: 0.95;
        }
    </style>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <h1><i class="fas fa-paw me-3"></i>About Pet Supplies Store</h1>
            <p>Your trusted partner in providing the best care and products for your beloved pets. We're passionate about keeping your furry, feathered, and scaly friends happy and healthy.</p>
        </div>
    </section>

    <!-- Features Section -->
    <section class="container mb-5">
        <h2 class="section-title">Why Choose Us?</h2>
        <div class="row g-4">
            <div class="col-lg-4 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-heart feature-icon"></i>
                    <h3 class="feature-title">Pet Lovers</h3>
                    <p class="feature-text">We're genuine pet enthusiasts who understand the special bond between you and your pets. Every product is selected with love and care.</p>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-award feature-icon"></i>
                    <h3 class="feature-title">Quality Products</h3>
                    <p class="feature-text">We source only the highest quality supplies, toys, and foods from trusted brands to ensure your pets get the best.</p>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-shipping-fast feature-icon"></i>
                    <h3 class="feature-title">Fast Delivery</h3>
                    <p class="feature-text">Quick and reliable shipping to get your pet supplies when you need them. Because we know your pets can't wait!</p>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-users feature-icon"></i>
                    <h3 class="feature-title">Expert Support</h3>
                    <p class="feature-text">Our knowledgeable team is always ready to help you choose the right products for your specific pet's needs.</p>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-shield-alt feature-icon"></i>
                    <h3 class="feature-title">Safe & Secure</h3>
                    <p class="feature-text">All our products meet safety standards, and your personal information is protected with industry-standard security.</p>
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-dollar-sign feature-icon"></i>
                    <h3 class="feature-title">Fair Pricing</h3>
                    <p class="feature-text">Competitive prices without compromising on quality. Great value for premium pet supplies and accessories.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section">
        <div class="container">
            <div class="row">
                <div class="col-lg-3 col-md-6">
                    <div class="stat-card">
                        <span class="stat-number">10,000+</span>
                        <div class="stat-label">Happy Pets Served</div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="stat-card">
                        <span class="stat-number">500+</span>
                        <div class="stat-label">Quality Products</div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="stat-card">
                        <span class="stat-number">98%</span>
                        <div class="stat-label">Customer Satisfaction</div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="stat-card">
                        <span class="stat-number">24/7</span>
                        <div class="stat-label">Customer Support</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Mission Section -->
    <section class="mission-section">
        <div class="container">
            <h2 class="section-title text-white">Our Mission</h2>
            <p class="mission-text">
                At Pet Supplies Store, we believe every pet deserves the best. Our mission is to provide pet owners with access to high-quality, 
                safe, and affordable products that enhance the lives of their beloved companions. We're not just selling products – 
                we're supporting the beautiful relationship between pets and their families.
            </p>
        </div>
    </section>

    <!-- What We Offer Section -->
    <section class="container team-section">
        <h2 class="section-title">What We Offer</h2>
        <div class="row g-4">
            <div class="col-lg-6 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-bone feature-icon"></i>
                    <h3 class="feature-title">Premium Pet Food</h3>
                    <p class="feature-text">Nutritious and delicious food options for dogs, cats, birds, fish, and other pets. All from trusted brands with quality ingredients.</p>
                </div>
            </div>
            <div class="col-lg-6 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-gamepad feature-icon"></i>
                    <h3 class="feature-title">Fun Toys & Accessories</h3>
                    <p class="feature-text">Engaging toys, comfortable beds, stylish collars, and accessories to keep your pets entertained and comfortable.</p>
                </div>
            </div>
            <div class="col-lg-6 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-medkit feature-icon"></i>
                    <h3 class="feature-title">Health & Wellness</h3>
                    <p class="feature-text">Vitamins, supplements, grooming supplies, and health products to maintain your pet's well-being.</p>
                </div>
            </div>
            <div class="col-lg-6 col-md-6">
                <div class="feature-card">
                    <i class="fas fa-home feature-icon"></i>
                    <h3 class="feature-title">Habitat Essentials</h3>
                    <p class="feature-text">Cages, aquariums, bedding, and habitat accessories for creating the perfect environment for your pets.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Info Section -->
    <section class="container mb-5">
        <div class="row">
            <div class="col-lg-8 mx-auto text-center">
                <h2 class="section-title">Get in Touch</h2>
                <p class="lead mb-4">Have questions about our products or need pet care advice? We'd love to hear from you!</p>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="feature-card">
                            <i class="fas fa-envelope feature-icon"></i>
                            <h4 class="feature-title">Email Us</h4>
                            <p class="feature-text">support@petsupplies.com</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="feature-card">
                            <i class="fas fa-phone feature-icon"></i>
                            <h4 class="feature-title">Call Us</h4>
                            <p class="feature-text">(555) 123-PETS</p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="feature-card">
                            <i class="fas fa-clock feature-icon"></i>
                            <h4 class="feature-title">Support Hours</h4>
                            <p class="feature-text">Mon-Fri: 9AM-8PM<br>Weekends: 10AM-6PM</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
