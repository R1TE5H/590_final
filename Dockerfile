# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY src/ src/
COPY tests/ tests/
COPY docs/ docs/
COPY Doxyfile .

# Install LaTeX, Doxygen, Graphviz, and zip
RUN apt-get update && apt-get install -y \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    doxygen \
    graphviz \
    zip \
    git \
    && apt-get clean

# Receive version as a build argument
ARG VERSION=1.0.0
ENV VERSION=$VERSION

# Inject version into LaTeX, compile PDF, run Doxygen, and create ZIP
RUN sed -i "s/VERSION_PLACEHOLDER/$VERSION/" docs/report.tex && \
    pdflatex docs/report.tex -output-directory=docs && \
    doxygen Doxyfile && \
    mkdir -p release && \
    zip -r release/my_devops_project_v$VERSION.zip src/ tests/ docs/report.pdf docs/doxygen/html Dockerfile requirements.txt

# Default command
CMD ["bash"]
