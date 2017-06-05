

# Overview

- Each issue is a task
- Each issue requires a time estimate in hours
	+ Estimate should be between 1 and 16
	+ Issues where estimate would be greater than 16 must be split
	+ The time estimate must be in the first comment (initial description) on the issue
- The last comment before the issue is closed must contain the actual time taken
- Each issue must be assigned to exactly one developer
- Issues labeled 'split' will not be counted


## The Labels


- Priority Level Labels
	+ Each issue must have a priority level label
	+ #ffffff
	+ Labels
		* Urgent
		* High
		* Important
		* Medium
		* Moderate
		* Low
		* None

- Platform
	+ If the repository covers multiple parts, this is how we designate where the issue lives. (i.e. iOS and Android for cross-platform tablet app).
	+ #bfd4f2

- Problems
	+ Issues that make the product feel broken. High priority, especially if its present in production.
	+ #EE3F46

- Mindless
	+ Converting measurements, reorganizing folder structure, and other necessary (but less impactful) tasks.
	+ #fef2c0

- Experience
	+ Affect user’s comprehension, or overall enjoyment of the product. These can be both opportunities and “UX bugs”.
	+ #FFC274

- Environment
	+ Server environment. With good QA, you’ll identify issues on test and staging deployments.
	+ #fad8c7

- Feedback
	+ Requires further conversation to figure out the action steps. Most feature ideas start here.
	+ #cc317c

- Improvements
	+ Iterations on existing features or infrastructure. Generally these update speed, or improve the quality of results. Adding a new “Owner” field to an existing “Calendar” model in the API, for example.
	+ #5EBEFF

- Additions
	+ Brand new functionality. New pages, workflows, endpoints, etc.
	+ #91ca55

- Pending
	+ Taking action, but need a few things to happen first. A feature that needs dependencies merged, or a bug that needs further data.
	+  #fbca04

- Inactive
	+ No action needed or possible. The issue is either fixed, addressed better by other issues, or just out of product scope.
	+ #D2DAE1
	+ Labels
		+ Split
		+ Don't Fix
		+ Invalid
		+ Duplicate
		+ On Hold
		+ Etc.








