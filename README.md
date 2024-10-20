# phpMyAdmin Installer

## Description

This script simplifies the installation of phpMyAdmin on your server. It supports various configurations including with and without MySQL, with or without a domain, and using Cloudflare as a proxy. It also provides an option to remove Cloudflare proxy settings and uninstall phpMyAdmin.

## Features

- **Install phpMyAdmin with a domain**
- **Install phpMyAdmin with a domain behind Cloudflare proxy**
- **Install phpMyAdmin without a domain**
- **Install phpMyAdmin and MySQL with a domain**
- **Install phpMyAdmin and MySQL with a domain behind Cloudflare proxy**
- **Install phpMyAdmin and MySQL without a domain**
- **Remove Cloudflare proxy settings**
- **Uninstall phpMyAdmin**

## Prerequisites

Ensure you have root or sudo access to your server and that `curl` is installed.

## Installation Instructions

1. **Download and Run the Script**

   To start the installation, execute the following command:

   ```bash
   bash <(curl -s https://raw.githubusercontent.com/y-nabeelxd/phpmyadmin-installer/main/main.sh)

2. **Follow the Menu Options**

   After running the script, you will see a menu with the following options:

   - **0) Install phpMyAdmin with a domain**
   - **1) Install phpMyAdmin with a domain behind Cloudflare proxy**
   - **2) Install phpMyAdmin without a domain**
   - **3) Install phpMyAdmin and MySQL with a domain**
   - **4) Install phpMyAdmin and MySQL with a domain behind Cloudflare proxy**
   - **5) Install phpMyAdmin and MySQL without a domain**
   - **6) Remove Cloudflare proxy settings**
   - **7) Uninstall phpMyAdmin**
   - **8) Cancel or Exit**

   Enter the number corresponding to your choice and follow the on-screen instructions.

## Cloudflare Proxy Configuration

If you choose to configure Cloudflare as a proxy, follow these steps:

1. **Set Up Your Domain on Cloudflare**

   - Log in to your Cloudflare account.
   - Add your domain to Cloudflare if you haven't done so already.
   - Configure DNS settings to point to your server’s IP address.

2. **Enable Cloudflare Proxy**

   - In the DNS settings on Cloudflare, ensure that the proxy status is enabled (indicated by an orange cloud icon).
   - This will enable Cloudflare to proxy your traffic and provide additional security.

3. **Update phpMyAdmin Configuration**

   - Ensure that your `phpMyAdmin` configuration handles Cloudflare correctly by checking for the `$_SERVER['HTTP_X_FORWARDED_FOR']` header for the original client IP addresses.

## Notes

- Ensure the domain you input (if choosing options with a domain) is properly set up and configured on your server.
- If you choose to install MySQL, make sure MySQL is installed and configured before running the script.

## Support

For issues or questions, please open an [issue](https://github.com/y-nabeelxd/phpmyadmin-installer/issues) on the GitHub repository.

## License

This script is licensed under the [MIT License](LICENSE).

---

Thank you for using the phpMyAdmin Installer by NabeelXD. We hope this script simplifies your server management!


Feel free to modify or expand on any sections as needed for your specific use case.
