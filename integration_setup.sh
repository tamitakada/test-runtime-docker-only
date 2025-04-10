echo "RUNNING INTEGRATION SETUP"

find . -name 'pom.xml' -print0 | xargs -0 -I {} xmlstarlet ed -L \
    -N ns="http://maven.apache.org/POM/4.0.0" \
    -s "/ns:project/ns:build/ns:pluginManagement/ns:plugins/ns:plugin[ns:artifactId='maven-surefire-plugin'][not(ns:configuration)]" -t elem -n "configuration" \
    -s "/ns:project/ns:build/ns:pluginManagement/ns:plugins/ns:plugin[ns:artifactId='maven-surefire-plugin']/ns:configuration[not(ns:skipTests)]" -t elem -n "skipTests" -v "\${skipSurefireTests}" \
    -s "/ns:project/ns:build/ns:plugins/ns:plugin[ns:artifactId='maven-surefire-plugin'][not(ns:configuration)]" -t elem -n "configuration" \
    -s "/ns:project/ns:build/ns:plugins/ns:plugin[ns:artifactId='maven-surefire-plugin']/ns:configuration[not(ns:skipTests)]" -t elem -n "skipTests" -v "\${skipSurefireTests}" \
    {}

echo "END INTEGRATION SETUP"
