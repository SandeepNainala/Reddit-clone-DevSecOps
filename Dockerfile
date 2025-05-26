# Dockerfile for Reddit Clone Application
# This Dockerfile sets up a Node.js environment for the Reddit clone application
FROM node:19-alpine3.15   

WORKDIR /reddit-clone    
# Set the working directory to /reddit-clone
# This is where the application code will be copied to
# and where commands will be run.
COPY . /reddit-clone   

# Copy the current directory contents into the container at /reddit-clone
# This includes the package.json and package-lock.json files
RUN npm install     

# Install the application dependencies
EXPOSE 3000          

CMD [ "npm", "run", "dev" ]