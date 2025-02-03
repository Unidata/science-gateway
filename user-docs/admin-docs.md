# NSF Unidata Science Gateway: JupyterHub Administrator Docs

---

This set of documentation consists mostly of answers to Frequently Asked Questions we have received over the years that pertain specifically to use of Jupyter on the NSF Unidata Science Gateway (USG). If you have a question that is not answered by this documentation, or an answer is unclear or ambiguous, please raise a new issue ([how to](https://foundations.projectpythia.org/foundations/github/github-issues.html)) in the NSF Unidata Science Gateway's [GitHub repository](https://github.com/Unidata/science-gateway/issues/new?template=Blank+issue) or email the USG Team at support-gateway@unidata.ucar.edu.

For general JupyterLab, Git, and GitHub help, see Project Pythia's "Foundations" cookbook for an excellent introduction to the topics.

[Project Pythia Foundatations: JupyterLab](https://foundations.projectpythia.org/foundations/jupyterlab.html)  
[Project Pythia Foundations: Git and GitHub](https://foundations.projectpythia.org/foundations/getting-started-github.html)

<details>
    <summary>More on Project Pythia</summary>
    <p>In their own words: "Project Pythia is a home for Python-centered learning resources that are open-source, community-owned, geoscience-focused, and high-quality."</p>
    <p>Visit the Project Pythia website at <a href="https://projectpythia.org">ProjectPythia.org</a>. In particular, their community contributed <a href="https://cookbooks.projectpythia.org">Cookbooks</a> show examples of some common workflows.</p>
    <p>Rose, Brian E. J., Clyne, John, May, Ryan, Munroe, James, Snyder, Amelia, Eroglu, Orhan, & Tyle, Kevin. (2023). Collaborative Research: GEO OSE TRACK 2: Project Pythia and Pangeo: Building an inclusive geoscience community through accessible, reusable, and reproducible workflows. Zenodo. https://doi.org/10.5281/zenodo.8184298</p>
</details>

---

## Table of Contents

[***Environment Management***](#Environment-Management)
- [How do I use my environment/kernel?](#How-do-I-use-my-environment/kernel?)
- [How can I create new conda environments/kernels?](#How-can-I-create-new-conda-environments/kernels?)
- [How can I share new python packages with all JupyterHub users?](#How-can-I-share-new-python-packages-with-all-JupyterHub-users?)
- [How can I update my server to include new (non-python) packages?](#How-can-I-update-my-server-to-include-new-\(non-python\)-packages?)

[***Administration***](#Administration)
- [How can I access the Admin page?](#How-can-I-access-the-Admin-page?)
- [What actions can I perform as an admin?](#What-actions-can-I-perform-as-an-admin?)
- [How do I add users?](#How-do-I-add-users?)

[***Git and GitHub***](#Git-and-GitHub)
- [What is GitHub syncing and how does it work?](#What-is-GitHub-syncing-and-how-does-it-work?)
- [How can I use JupyterHub to push to my git repositories?](#How-can-I-use-JupyterHub-to-push-to-my-git-repositories?)
- [Can I sync or manage a private GitHub repository from Jupyter?](#Can-I-sync-or-manage-a-private-GitHub-repository-from-Jupyter?)

[***Containerization and Storage***](#Containerization-and-Storage)
- [What is "containerization", and how does it relate to my JupyterHub?](#What-is-"containerization",-and-how-does-it-relate-to-my-JupyterHub?)
- [Will users share the same home directory, `/home/jovyan`?](#Will-users-share-the-same-home-directory,-/home/jovyan?)
- [Can I store files outside of my home directory?](#Can-I-store-files-outside-of-my-home-directory?)
- [How do I upload files to JupyterHub?](#How-do-I-upload-files-to-JupyterHub?)
- [How do I download files from JupyterHub?](#How-do-I-download-files-from-JupyterHub?)

---

### Environment Management
[[Back to Top]](#Table-of-Contents)

#### How do I use my environment/kernel?

We configure your JupyterHub to make your kernel the default kernel for any existing notebooks (i.e. files with the `.ipynb` extension). When creating a new notebook, a dialog box will allow you to specify which kernel it should use. To change the kernel of an existing notebook, open the notebook and in the JupyterLab toolbar click `Kernel --> Change Kernel...`.
<details>
    <summary>Kernel in a New Notebook</summary>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/new-launcher.png" width="751" height="380" alt="The new launcher button is found on the top of the left sidebar"></img>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/launcher-select-kernel.png" width="751" height="380" alt="Create a new notebook by selecting the appropriate kernel"></img>
</details>

<details>
    <summary>Kernel in an Existing Notebook</summary>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/notebook-switch-kernel.png" width="751" height="380" alt="In The JupyterLab toolbar, click 'Kernel --> Change Kernel...'"></img>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/notebook-select-kernel.png" width="751" height="380" alt="A popup window with a dropdown kernel select menu"></img>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/notebook-kernel-dropdown.png" width="751" height="380" alt="Select the desired kernel from the dropdown menu"></img>
</details>

[[Back to Top]](#Table-of-Contents)

#### How can I create new conda environments/kernels?

Note that these instructions will create a new environment/kernel *for your user only* and we recommend you use this feature for development purposes. To make new environments available to more users, see [here](#How-can-I-share-new-python-packages-with-all-JupyterHub-users?).

To have a useful starting point, use a terminal to copy the default environment file to your home directory: `cp /tmp/environment.yml ~/my-environment.yml`. Edit it to your liking, being sure to keep the packages found in the section marked by a `# Required by JupyterLab` comment.

You will ***need*** to instruct `conda` to install new environments in either your home directory or your shared drive. See Read More below for details.

Afterwards, run `mamba env update --name myenv -f my-environment.yml`.

Your kernel should now be available for use. It may take a few minutes for Jupyter to detect the new kernel.

<details>
    <summary>Read More</summary>
    <p>
        If you install a new environment in the default location, <code>/opt/conda</code>, the environment will not persist between sessions due to a quirk of containerization <a href="#Can-I-store-files-outside-of-my-home-directory?">containerization</a>.
    </p>
    <p>
        Instead, instruct <code>conda</code> to install new environments in either your home directory or your shared drive, create or edit your <code>~/.condarc</code> file using a terminal text editor such as <code>vim</code> or <code>nano</code>.
    </p>
    <p>
        <pre>
            <code>
                envs_dirs:
                  # Uncomment (delete the "#") the first item to install in your home directory,
                  # and the second item to install in your shared drive
                  #- /home/jovyan/additional-envs
                  #- /home/jovyan/share/additional-envs
            </code>
        </pre>
    </p>
    <p>
        Depending on the packages installed, conda environments can be quite large, and your home directory may fill up. If you have a shared drive available, it is recommended you create and <code>additional-envs</code> directory there to make use of the space. See your current disk usage by running the following in a terminal: <code>df -h</code>.
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### How can I share new python packages with all JupyterHub users?

Option 1: [Create a new kernel](#How-can-I-create-new-conda-environments/kernels?) in a shared drive, should you have one. Instruct
your users to make the same edits to their `~/.condarc` as you have. Their
JupyterLab server should now detect the new kernel with the new packages.

Option 2: Contact the NSF Unidata Science Gateway team via an existing email
thread, or start a new one: support-gateway@unidata.ucar.edu. We will update
your JupyterHub to ensure the packages are available to all users.

[[Back to Top]](#Table-of-Contents)

#### How can I update my server to include new (non-python) packages?

Contrary to conda environments, non-python packages (anything installed by a package manager, such as `apt`) cannot be managed by users, even if they are administrators of the JupyterHub. If you require additional packages, please reach out to the NSF Unidata Science Gateway team in an existing email thread, or start a new one: support-gateway@unidata.ucar.edu. We will update your JupyterHub to ensure the packages are available to all users.

[[Back to Top]](#Table-of-Contents)

---

### Administration
[[Back to Top]](#Table-of-Contents)

#### How can I access the Admin page?

Access the admin page by appending `/hub/admin` to your JupyterHub's URL. For example: `https://unidata-1.ees220002.projects.jetstream-cloud.org/hub/admin`. Alternatively, use the JupyterLab toolbar to navigate to `File --> Hub Control Panel`. You can then access the Admin page with the link on the top bar.

<details>
    <summary>Accessing the Admin Page</summary>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/hub-control-panel.png" align="top" width="400" height="500" alt="Select 'File --> Hub Control Panel' from the JupyterLab toolbar"></img>
    <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/admin-link.png" align="top" width="750" height="380" alt="Select 'File --> Hub Control Panel' from the JupyterLab toolbar"></img>
</details>

[[Back to Top]](#Table-of-Contents)

#### What actions can I perform as an admin?

As a JupyterHub administrator, you have the ability to:
- Add or remove users
- Start and stop user servers
- Access user servers and see their data

<details>
    <summary>Read More</summary>
    <p>
        <ul>
            <li>Removing a user will also delete all their data. Use with caution!</li>
            <li>Some instructors ask their students to complete assignments and place them in an agreed upon path. They can then access students' notebook for grading.</li>
        </ul>
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### How do I add users?

After accessing the Admin page, simply click the "Add Users" button located on the top row of the Users list. Input one or many GitHub usernames, one on each line, then click "Add Users" to complete the add.
<details>
    <summary>Read More</summary>
    <p>To add users, first <a href="#How-can-I-access-the-Admin-page?">access the admin panel.</a> Then:</p>
        <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/admin-page.png" align="top" width="" height="" alt="Click on the 'Add Users' button at the top left of the users list"></img>
        <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/add-users-text-area.png" align="top" width="" height="" alt="Add new user's GitHub user names in the text area, one on each line"></img>
        <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/add-new-users.png" align="top" width="" height="" alt="Click the 'Add Users' button to confirm"></img>
        <img src="https://raw.githubusercontent.com/Unidata/science-gateway/refs/heads/master/user-docs/images/add-new-admins.png" align="top" width="" height="" alt="Optionally, check the 'Admin' checkbox to give the new users admin permissions"></img>
</details>

[[Back to Top]](#Table-of-Contents)

---

### Git and GitHub
[[Back to Top]](#Table-of-Contents)

#### What is GitHub syncing and how does it work?

Given a public or private (see [here](#git-3)) GitHub repository, we can configure
your JupyterHub to automatically clone the repository and pull in changes to
each user's home directory whenever they log in, or when they run the
`~/update_materials.ipynb` convenience notebook.

Note that users (including admins) should *not* make any commits to the cloned
repository. See Read More for details.

<details>
    <summary>Read More</summary>
    <p>
	When accessing the cloned repository in your home directory, you should not make any commits. Syncing JupyterHub with your Git repository uses a tool called <code>gitpuller</code>, a wrapper around <code>git</code> that will perform a <code>git reset --mixed</code>, which will attempt to merge the "local" (i.e. on Jupyter) repository with the remote repository. If you commit changes to the local repository, it will "diverge" from the remote repository and require manual <code>git</code> wizardry to resolve.
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### How can I use JupyterHub to push to my git repositories?

If you want to develop notebooks on JupyterHub and push them to the same
synced repository, create a "development" repository for this purpose. Either
use the terminal (`cp -r my-repo my-repo-dev`) or the JupyterLab File Browser in
the sidebar (right click --> copy --> paste).

To push, you will need to create an appropriately scoped Personal Access Token
(PAT). See Read More for details.

<details>
    <summary>Read More</summary>
    <p>
        To create a PAT with push permission to your repo:
	<ol>
	    <li>Log in to GitHub</li>
	    <li>On the top right of the GitHub page, click on your profile and access your "Settings" on the menu</li>
	    <li>Navigate to the "Developer Settings" page, located as the last entry in the left side bar/menu</li>
	    <li>Access the "Fine-grained tokens" page, once again via the side bar/menu under "Personal access tokens"</li>
	    <li>"Generate new token"</li>
	    <li>Specify a name and expiration date</li>
	    <li>Under the "Repository access" section, select the "Only select repositories" radio button, and select your repo</li>
	    <li>Expand "Repository permissions" in the "Permissions" section</li>
	    <li>Grant "Access: Read and Write" to "Contents". This will also automatically give the PAT Read-Only access to the repo's metadata and Read and Write access to "Commit Statuses"</li>
	    <li>Double check the Overview and generate the token</li>
	    <li>Take note of the token; it is only visible until you leave/refresh the page</li>
	</ol>
    </p>
    <p>
	Put your token on your JupyterLab server. Note that it will be stored in plain text in your home directory.
	<ol>
	    <li>Create a new file in you Jupyter home directory named <code>.git-credentials</code></li>
	    <li>Add this to the file: <code>https://<your-username>:<PAT>@github.com</code></li>
	    <li>From a terminal run <code>git config credential.helper store</code></li>
	    <li>You should now be able to push to your repository</li>
	</ol>
    </p>
    <p>
        Paragraph
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### Can I sync or manage a private GitHub repository from Jupyter?

In principle, we can configure the JupyterHub to pull in repositories hosted in places other than GitHub such as GitLab or BitBucket, although we cannot guarantee proper functionality.

<details>
    <summary>Read More</summary>
    <p>
        We have the capability to clone/pull private GitHub repositories, however you must be comfortable with providing us with a Personal Access Token (PAT) that we will place in your users' home directories. Follow these instructions to create a fine-grained PAT:
    	<ol>
    	    <li>Log in to GitHub</li>
    	    <li>On the top right of the GitHub page, click on your profile and access your "Settings" on the menu</li>
    	    <li>Navigate to the "Developer Settings" page, located as the last entry in the left side bar/menu</li>
    	    <li>Access the "Fine-grained tokens" page, once again via the side bar/menu under "Personal access tokens"</li>
    	    <li>"Generate new token"</li>
    	    <li>Specify a name and expiration date</li>
    	    <li>Under the "Repository access" section, select the "Only select repositories" radio button, and select your repo</li>
    	    <li>Expand "Repository permissions" in the "Permissions" section</li>
    	    <li>Grant "Access: Read-only" to "Contents". This will also automatically give the PAT Read-Only access to the repo's metadata</li>
    	    <li>Double check the Overview and generate the token</li>
    	    <li>Send the token to the science gateway team, the token is only visible until you leave/refresh the page</li>
    	</ol>
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

---

### Containerization and Storage
[[Back to Top]](#Table-of-Contents)

#### What is "containerization", and how does it relate to my JupyterHub?

Containerization is a process by which applications, such as JupyterLab, are packaged into a container "image". These static images are easily shareable and can be used to create multiple "containers", each with a uniform environment. When a user logs in to JupyterHub, a container is created for them. When they log out, this container is destroyed.

<details>
    <summary>Read More</summary>
    <p></p>
    <p>
        Our JupyterHubs are <a href="https://z2jh.jupyter.org/en/stable/">deployed on top of Kubernetes</a>, a "container orchestration engine" which simplifies much of the workload associated with setting up a JupyterHub server, including container creation/destruction, networking, and volume storage allocation.
    </p>
    <p>
        We don't expect our users to ever have to work with Kubernetes, but we are happy to share knowledge if desired.
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### Will users share the same home directory, `/home/jovyan`?

While the home directories for each user are named the same, they exist on different file systems, so they will only ever see their own data and there will be no "crossing of wires." We have the capability to enable a shared drive, if desired, so all users may access some shared data.

<details>
    <summary>Read More</summary>
    <p></p>
    <p>
        Our JupyterHub deployments are done via the container orchestration technology "Kubernetes". As such, each user's <code>/home/jovyan</code> is actually a cloud storage volume attached to a different container (a similar abstraction to a virtual machine).
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### Can I store files outside of my home directory?

No. Your JupyterLab servers are containerized; when a user logs out the server, the container and all of its data is destroyed. User's home directories are exempt from this, as user data exists separatedly from the container. This acts as if you were to keep all your data on a physical thumb drive that you move from machine to machine whenever you need to do work.
<details>
    <summary>Read More</summary>
    <p></p>
    <p>
        The only other exception to this is a shared drive, which we typically mount on <code>/share</code> and, similarly to user data, exists as a separate entity from the JupyterLab containers.
    </p>
    <p>
        This quirk of JupyterHub has implications regarding environment management. 
    </p>
</details>

[[Back to Top]](#Table-of-Contents)

#### How do I upload files to JupyterHub?

JupyterHub/Lab has various options for adding files, such as data sets, to either your home directories or shared drive (if you've requested one).

- Use the File Explorer's upload feature
- Use `wget` or `curl` from the terminal if the files already exist on some server
- Use an `ssh` connection to `scp` or `rsync` files from your local machines to your shared drive.

<details>
    <summary>Read More: Upload with the File Explorer</summary>
    <p></p>
    <p>By default, there is a limit of 500MB upload file size, this is to prevent the server from being overloaded with large requests, malicious or otherwise. If you need to add larger files to your JupyterHub, consider the more advanced options of using <code>wget</code>, <code>curl</code>, <code>scp</code>, or <code>rsync</code>.</p>
    <p>The upload button is found at the top bar of the file explorer. Clicking it will open up your OS's file explorer for you to browse and select the appropriate file(s).</p>
</details>
<details>
    <summary>Read More: scp and rsync</summary>
    <p></p>
    <p>SSH access into your shared drive is typically reserved for special cases where neither JupyterLab's file upload feature, <code>wget</code>, nor <code>curl</code> are appropriate for the task of getting your files onto JupyterHub. If you think this applies to you, get in contact with the NSF Unidata Science Gateway team in an existing email chain or start a new one by sending an email to support-gateway@unidata.ucar.edu.</p>
    <p>We will provide more specific instructions on how to access the SSH server at that time. We require that you provide us with the public key for authentication into the server. GitHub has instructions on how to create a public-private key pair <a href="https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent">here</a>.</p>
</details>

[[Back to Top]](#Table-of-Contents)

#### How do I download files from JupyterHub?

Individual files can be downloaded by Right Click-ing them in the File Explorer and selecting "Download". Multiple files can be downloaded at once by holding down the "Ctrl" key (or "Command" key, for MacOS), Left Click-ing each file, and finally Right Click-ing them and selecting "Download."

<details>
    <summary>Read More: Downloading as archives (.zip files)</summary>
    <p></p>
    <p>Downloading multiple files using the method described above can be clunky for large amounts of files. Instead, you can put all desired files into an "archive", e.g. a <code>.zip</code> file. This method allows you to download many files and folders at once while preserving the directory structure. Accomplish this by:</p>
    <p>
        <ol>
            <li>Using the JupyterLab File Explorer, navigate to the folder containing your files</li>
            <li>Open a new Terminal in JupyterLab, it should open in the desired folder; confirm by running the <code>pwd</code> (print working directory) command</li>
            <li>In the terminal, run the following command: <code>zip my_zip_file.zip example1.ipynb example2.ipynb notebooks/</code></li>
            <li>Download the newly created zip file by Right Click-ing it in the File Explorer and selecting "Download"</li>
            <li>You can now unzip the file on your own machine using archiving software like WinRAR or 7-zip</li>
        </ol>
    </p>
</details>

---

