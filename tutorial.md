# Google Workspace Audit Setup

Learn how to set up your Google Cloud project, enable the required APIs, generate a Service Account key, and configure Domain-Wide Delegation.

---

## 1. Run Automated GCP Setup

Click the **Cloud Code** execute button on the snippet below to run the provisioning script. This creates the project, enables the required APIs, creates `gws-audit-sa`, and generates the JSON key[cite: 1, 2].

```bash
chmod +x setup.sh
./setup.sh
```

---

## 2. Configure Domain-Wide Delegation

Google Workspace requires manual authorization for Domain-Wide Delegation by a Super Admin[cite: 1, 2].

1. Open the [Google Admin Console Domain-Wide Delegation](https://admin.google.com/ac/owl/domainwidedelegation) page[cite: 2].
2. Click **Add new**[cite: 2].
3. Paste the **Client ID** output by the script in Step 1[cite: 2].
4. In the **OAuth Scopes** field, copy and paste the comma-separated scopes below[cite: 1, 2]:

```text
[https://www.googleapis.com/auth/admin.reports.audit.readonly,https://www.googleapis.com/auth/admin.directory.user.readonly,https://www.googleapis.com/auth/admin.directory.device.mobile.readonly,https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly,https://www.googleapis.com/auth/gmail.readonly,https://www.googleapis.com/auth/drive.metadata.readonly,https://www.googleapis.com/auth/apps.alerts](https://www.googleapis.com/auth/admin.reports.audit.readonly,https://www.googleapis.com/auth/admin.directory.user.readonly,https://www.googleapis.com/auth/admin.directory.device.mobile.readonly,https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly,https://www.googleapis.com/auth/gmail.readonly,https://www.googleapis.com/auth/drive.metadata.readonly,https://www.googleapis.com/auth/apps.alerts)
```

5. Click **Authorize**[cite: 2].

---

## 3. Download the Key & Run the Notebook

Your key file `gws-audit-sa-key.json` was generated in the current directory[cite: 1, 2].

Run this command to download it to your local machine:

```bash
cloudshell download gws-audit-sa-key.json
```

You can now upload this key to [Google Colab](https://colab.research.google.com) and run `GWS_Security_Audit.ipynb`[cite: 1, 2].
